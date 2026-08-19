/**
 * Data collection module — aggregates Pi session data into UsageData.
 *
 * Exports a single public function `getUsageData(signal?)` and several
 * test-facing helpers: computeTimeBoundaries, aggregateSessionMessages,
 * computeInsights.
 */

import type {
  UsageData,
  TimeFilteredStats,
  PeriodRawData,
  RawMessage,
  PeriodInsights,
  Insight,
  ModelStats,
  ProviderStats,
  TotalStats,
  TokenStats,
  BaseStats,
  GlobalSessionSpan,
} from "./types.js";
import { readdir, readFile } from "node:fs/promises";
import { join } from "node:path";
import { homedir } from "node:os";

// =============================================================================
// Exported types (test-facing)
// =============================================================================

export interface ParsedMessage {
  provider: string;
  model: string;
  cost: number;
  input: number;
  output: number;
  cacheRead: number;
  cacheWrite: number;
  timestamp: number;
}

export interface SessionMessages {
  sessionId: string;
  messages: ParsedMessage[];
}

export interface TimeBoundaries {
  nowMs: number;
  todayMs: number;
  yesterdayMs: number;
  weekStartMs: number;
  lastWeekStartMs: number;
  monthStartMs: number;
  lastHourMs: number;
}

// =============================================================================
// Constants (mirror index.ts)
// =============================================================================

const PARALLEL_WINDOW_MS = 2 * 60_000;
const PARALLEL_SESSION_THRESHOLD = 4;
const LARGE_CONTEXT_THRESHOLD = 150_000;
const LARGE_CACHE_MISS_THRESHOLD = 100_000;
const LONG_SESSION_MS = 8 * 60 * 60 * 1000;
const TOP_SESSION_COUNT = 5;
const MIN_MESSAGES_FOR_PARALLEL_INSIGHT = 10;
const MIN_PERCENT_TO_SHOW = 1;

// =============================================================================
// Helpers
// =============================================================================

function emptyTokens(): TokenStats {
  return { total: 0, input: 0, output: 0, cacheRead: 0, cacheWrite: 0 };
}

function emptyModelStats(): ModelStats {
  return { sessions: new Set(), messages: 0, cost: 0, tokens: emptyTokens() };
}

function emptyProviderStats(): ProviderStats {
  return { sessions: new Set(), messages: 0, cost: 0, tokens: emptyTokens(), models: new Map() };
}

function emptyTimeFilteredStats(): TimeFilteredStats {
  return {
    providers: new Map(),
    totals: { sessions: 0, messages: 0, cost: 0, tokens: emptyTokens() },
    insights: { insights: [] },
  };
}

function emptyUsageData(): UsageData {
  return {
    lastHour: emptyTimeFilteredStats(),
    today: emptyTimeFilteredStats(),
    yesterday: emptyTimeFilteredStats(),
    thisWeek: emptyTimeFilteredStats(),
    lastWeek: emptyTimeFilteredStats(),
    thisMonth: emptyTimeFilteredStats(),
    allTime: emptyTimeFilteredStats(),
  };
}

function emptyPeriodRawData(): PeriodRawData {
  return { messages: [], sessionCosts: new Map() };
}

function accumulateStats(
  target: BaseStats,
  cost: number,
  tokens: { total: number; input: number; output: number; cacheRead: number; cacheWrite: number }
): void {
  target.messages++;
  target.cost += cost;
  target.tokens.total += tokens.total;
  target.tokens.input += tokens.input;
  target.tokens.output += tokens.output;
  target.tokens.cacheRead += tokens.cacheRead;
  target.tokens.cacheWrite += tokens.cacheWrite;
}

// =============================================================================
// computeTimeBoundaries
// =============================================================================

export function computeTimeBoundaries(nowMs?: number): TimeBoundaries {
  const now = nowMs ?? Date.now();

  const startOfToday = new Date(now);
  startOfToday.setUTCHours(0, 0, 0, 0);
  const todayMs = startOfToday.getTime();

  const startOfYesterday = new Date(startOfToday);
  startOfYesterday.setUTCDate(startOfYesterday.getUTCDate() - 1);
  const yesterdayMs = startOfYesterday.getTime();

  // Start of current week (Monday 00:00 UTC)
  const startOfWeek = new Date(now);
  const dayOfWeek = startOfWeek.getUTCDay(); // 0 = Sunday, 1 = Monday...
  const daysSinceMonday = dayOfWeek === 0 ? 6 : dayOfWeek - 1;
  startOfWeek.setUTCDate(startOfWeek.getUTCDate() - daysSinceMonday);
  startOfWeek.setUTCHours(0, 0, 0, 0);
  const weekStartMs = startOfWeek.getTime();

  // Start of last week
  const startOfLastWeek = new Date(startOfWeek);
  startOfLastWeek.setUTCDate(startOfLastWeek.getUTCDate() - 7);
  const lastWeekStartMs = startOfLastWeek.getTime();

  // Start of this month
  const startOfMonth = new Date(now);
  startOfMonth.setUTCDate(1);
  startOfMonth.setUTCHours(0, 0, 0, 0);
  const monthStartMs = startOfMonth.getTime();

  const lastHourMs = now - 60 * 60 * 1000;

  return { nowMs: now, todayMs, yesterdayMs, weekStartMs, lastWeekStartMs, monthStartMs, lastHourMs };
}

// =============================================================================
// aggregateSessionMessages
// =============================================================================

export function aggregateSessionMessages(
  sessions: SessionMessages[],
  boundaries: TimeBoundaries,
  _nowMs: number
): UsageData {
  const data = emptyUsageData();
  const seenHashes = new Set<string>();
  const rawByPeriod: Record<string, PeriodRawData> = {
    lastHour: emptyPeriodRawData(),
    today: emptyPeriodRawData(),
    yesterday: emptyPeriodRawData(),
    thisWeek: emptyPeriodRawData(),
    lastWeek: emptyPeriodRawData(),
    thisMonth: emptyPeriodRawData(),
    allTime: emptyPeriodRawData(),
  };
  const globalSessionSpans = new Map<string, GlobalSessionSpan>();

  for (const session of sessions) {
    const sessionContributed: Record<string, boolean> = {
      lastHour: false,
      today: false,
      yesterday: false,
      thisWeek: false,
      lastWeek: false,
      thisMonth: false,
      allTime: false,
    };

    for (const msg of session.messages) {
      // Track session span for long-session insight
      if (msg.timestamp > 0) {
        const span = globalSessionSpans.get(session.sessionId);
        if (!span) {
          globalSessionSpans.set(session.sessionId, { startMs: msg.timestamp, endMs: msg.timestamp });
        } else {
          if (msg.timestamp < span.startMs) span.startMs = msg.timestamp;
          if (msg.timestamp > span.endMs) span.endMs = msg.timestamp;
        }
      }

      // Deduplication: timestamp:tokens hash
      const totalTokens = msg.input + msg.output + msg.cacheRead + msg.cacheWrite;
      const hash = `${msg.timestamp}:${totalTokens}`;
      if (seenHashes.has(hash)) continue;
      seenHashes.add(hash);

      const tokens = {
        total: msg.input + msg.output + msg.cacheWrite,
        input: msg.input,
        output: msg.output,
        cacheRead: msg.cacheRead,
        cacheWrite: msg.cacheWrite,
      };

      // Determine which scopes this message belongs to
      const scopes: string[] = [];
      if (msg.timestamp >= boundaries.lastHourMs) scopes.push("lastHour");
      if (msg.timestamp >= boundaries.todayMs) scopes.push("today");
      if (msg.timestamp >= boundaries.yesterdayMs && msg.timestamp < boundaries.todayMs) scopes.push("yesterday");
      if (msg.timestamp >= boundaries.weekStartMs) scopes.push("thisWeek");
      if (msg.timestamp >= boundaries.lastWeekStartMs && msg.timestamp < boundaries.weekStartMs) scopes.push("lastWeek");
      if (msg.timestamp >= boundaries.monthStartMs) scopes.push("thisMonth");
      scopes.push("allTime");

      for (const scope of scopes) {
        const stats = data[scope as keyof UsageData] as TimeFilteredStats;

        let providerStats = stats.providers.get(msg.provider);
        if (!providerStats) {
          providerStats = emptyProviderStats();
          stats.providers.set(msg.provider, providerStats);
        }

        let modelStats = providerStats.models.get(msg.model);
        if (!modelStats) {
          modelStats = emptyModelStats();
          providerStats.models.set(msg.model, modelStats);
        }

        modelStats.sessions.add(session.sessionId);
        accumulateStats(modelStats, msg.cost, tokens);

        providerStats.sessions.add(session.sessionId);
        accumulateStats(providerStats, msg.cost, tokens);

        accumulateStats(stats.totals, msg.cost, tokens);
        sessionContributed[scope] = true;

        const raw = rawByPeriod[scope];
        if (raw) {
          raw.messages.push({
            sessionId: session.sessionId,
            timestamp: msg.timestamp,
            cost: msg.cost,
            input: msg.input,
            cacheRead: msg.cacheRead,
            cacheWrite: msg.cacheWrite,
          });
          raw.sessionCosts.set(session.sessionId, (raw.sessionCosts.get(session.sessionId) ?? 0) + msg.cost);
        }
      }
    }

    // Increment session counts once per session per scope
    if (sessionContributed.lastHour) data.lastHour.totals.sessions++;
    if (sessionContributed.today) data.today.totals.sessions++;
    if (sessionContributed.yesterday) data.yesterday.totals.sessions++;
    if (sessionContributed.thisWeek) data.thisWeek.totals.sessions++;
    if (sessionContributed.lastWeek) data.lastWeek.totals.sessions++;
    if (sessionContributed.thisMonth) data.thisMonth.totals.sessions++;
    if (sessionContributed.allTime) data.allTime.totals.sessions++;
  }

  // Classify long-running sessions globally, then compute insights per period
  const longSessionIds = new Set<string>();
  for (const [id, span] of globalSessionSpans) {
    if (span.endMs - span.startMs >= LONG_SESSION_MS) longSessionIds.add(id);
  }

  const SCOPE_ORDER = ["lastHour", "today", "yesterday", "thisWeek", "lastWeek", "thisMonth", "allTime"];
  for (const period of SCOPE_ORDER) {
    const raw = rawByPeriod[period];
    if (raw) {
      (data[period as keyof UsageData] as TimeFilteredStats).insights = computeInsights(raw, longSessionIds);
    }
  }

  return data;
}

// =============================================================================
// computeInsights
// =============================================================================

function formatThresholdTokens(n: number): string {
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`;
  if (n >= 1_000) return `${Math.round(n / 1000)}k`;
  return String(n);
}

function computeParallelCostWeight(messages: RawMessage[]): number | null {
  const timed = messages.filter((m) => m.timestamp > 0);
  if (timed.length < MIN_MESSAGES_FOR_PARALLEL_INSIGHT) return null;
  const distinctSessions = new Set(timed.map((m) => m.sessionId));
  if (distinctSessions.size < PARALLEL_SESSION_THRESHOLD) return null;

  const sorted = timed.slice().sort((a, b) => a.timestamp - b.timestamp);
  const sidCount = new Map<string, number>();
  let uniqueCount = 0;
  let left = 0;
  let right = 0;
  let parallelCost = 0;

  for (let i = 0; i < sorted.length; i++) {
    const current = sorted[i]!;
    const high = current.timestamp + PARALLEL_WINDOW_MS;
    const low = current.timestamp - PARALLEL_WINDOW_MS;

    while (right < sorted.length && sorted[right]!.timestamp <= high) {
      const sid = sorted[right]!.sessionId;
      const next = (sidCount.get(sid) ?? 0) + 1;
      sidCount.set(sid, next);
      if (next === 1) uniqueCount++;
      right++;
    }
    while (left < right && sorted[left]!.timestamp < low) {
      const sid = sorted[left]!.sessionId;
      const next = (sidCount.get(sid) ?? 0) - 1;
      if (next === 0) {
        sidCount.delete(sid);
        uniqueCount--;
      } else {
        sidCount.set(sid, next);
      }
      left++;
    }

    if (uniqueCount >= PARALLEL_SESSION_THRESHOLD) parallelCost += current.cost;
  }

  return parallelCost;
}

export function computeInsights(raw: PeriodRawData, longSessionIds: Set<string>): PeriodInsights {
  if (raw.messages.length === 0) {
    return { insights: [] };
  }

  const total = raw.messages.reduce((sum, m) => sum + m.cost, 0);
  if (total <= 0) {
    return { insights: [] };
  }

  const candidates: Insight[] = [];

  // 1. Parallel sessions
  const parallelWeight = computeParallelCostWeight(raw.messages);
  if (parallelWeight !== null) {
    candidates.push({
      percent: (parallelWeight / total) * 100,
      headline: `of your cost was while ${PARALLEL_SESSION_THRESHOLD}+ sessions ran in parallel`,
      advice:
        "All sessions share one rate limit. If you don't need them all at once, queueing uses capacity more evenly.",
    });
  }

  // 2. Large context
  const largeContextWeight = raw.messages
    .filter((m) => m.input + m.cacheRead + m.cacheWrite > LARGE_CONTEXT_THRESHOLD)
    .reduce((sum, m) => sum + m.cost, 0);
  candidates.push({
    percent: (largeContextWeight / total) * 100,
    headline: `of your cost was at >${formatThresholdTokens(LARGE_CONTEXT_THRESHOLD)} context`,
    advice:
      "Longer sessions are more expensive even when cached. /compact mid-task, /clear when switching to new tasks.",
  });

  // 3. Large uncached prompt
  const uncachedWeight = raw.messages
    .filter((m) => m.input + m.cacheWrite > LARGE_CACHE_MISS_THRESHOLD)
    .reduce((sum, m) => sum + m.cost, 0);
  candidates.push({
    percent: (uncachedWeight / total) * 100,
    headline: `of your cost came from >${formatThresholdTokens(LARGE_CACHE_MISS_THRESHOLD)}-token uncached prompts`,
    advice:
      "Uncached input is expensive, and often happens when sending a message to a session that has gone idle. /compact before stepping away keeps the cold-start small.",
  });

  // 4. Long-running sessions
  const longWeight = raw.messages
    .filter((m) => longSessionIds.has(m.sessionId))
    .reduce((sum, m) => sum + m.cost, 0);
  if (longWeight > 0) {
    candidates.push({
      percent: (longWeight / total) * 100,
      headline: `of your cost came from sessions active for ${LONG_SESSION_MS / 3_600_000}+ hours`,
      advice:
        "These are often background/loop sessions. Continuous usage can add up quickly so make sure it is intentional.",
    });
  }

  // 5. Top-N session concentration
  if (raw.sessionCosts.size > TOP_SESSION_COUNT) {
    const sortedSessions = Array.from(raw.sessionCosts.values()).sort((a, b) => b - a);
    const topN = Math.min(TOP_SESSION_COUNT, sortedSessions.length);
    const topWeight = sortedSessions.slice(0, topN).reduce((sum, c) => sum + c, 0);
    candidates.push({
      percent: (topWeight / total) * 100,
      headline: `of your cost came from your top ${topN} session${topN === 1 ? "" : "s"}`,
      advice:
        "A small number of sessions drives most of your spend. The table view can help pinpoint which ones.",
    });
  }

  const insights = candidates
    .filter((i) => i.percent >= MIN_PERCENT_TO_SHOW)
    .sort((a, b) => b.percent - a.percent);
  return { insights };
}

// =============================================================================
// File I/O — session file scanning
// =============================================================================

function getSessionsDir(): string {
  const agentDir = process.env.PI_CODING_AGENT_DIR || join(homedir(), ".pi", "agent");
  return join(agentDir, "sessions");
}

async function collectSessionFilesRecursively(dir: string, files: string[], signal?: AbortSignal): Promise<void> {
  try {
    const entries = await readdir(dir, { withFileTypes: true });
    for (const entry of entries) {
      if (signal?.aborted) return;
      const entryPath = join(dir, entry.name);
      if (entry.isDirectory()) {
        await collectSessionFilesRecursively(entryPath, files, signal);
      } else if (entry.isFile() && entry.name.endsWith(".jsonl")) {
        files.push(entryPath);
      }
    }
  } catch {
    // Skip directories we can't read
  }
}

async function getAllSessionFiles(signal?: AbortSignal): Promise<string[]> {
  const files: string[] = [];
  await collectSessionFilesRecursively(getSessionsDir(), files, signal);
  files.sort();
  return files;
}

interface ParsedSessionFile {
  sessionId: string;
  messages: ParsedMessage[];
}

async function parseSessionFile(
  filePath: string,
  seenHashes: Set<string>,
  signal?: AbortSignal
): Promise<ParsedSessionFile | null> {
  try {
    const content = await readFile(filePath, "utf8");
    if (signal?.aborted) return null;
    const lines = content.trim().split("\n");
    const messages: ParsedMessage[] = [];
    let sessionId = "";

    for (let i = 0; i < lines.length; i++) {
      if (signal?.aborted) return null;
      if (i % 500 === 0) {
        await new Promise<void>((resolve) => setImmediate(resolve));
      }
      const line = lines[i]!;
      if (!line.trim()) continue;
      try {
        const entry = JSON.parse(line);

        if (entry.type === "session") {
          sessionId = entry.id;
        } else if (entry.type === "message" && entry.message?.role === "assistant") {
          const msg = entry.message;
          if (msg.usage && msg.provider && msg.model) {
            const input = msg.usage.input || 0;
            const output = msg.usage.output || 0;
            const cacheRead = msg.usage.cacheRead || 0;
            const cacheWrite = msg.usage.cacheWrite || 0;
            const fallbackTs = entry.timestamp ? new Date(entry.timestamp).getTime() : 0;
            const timestamp = msg.timestamp || (Number.isNaN(fallbackTs) ? 0 : fallbackTs);

            // Deduplicate
            const totalTokens = input + output + cacheRead + cacheWrite;
            const hash = `${timestamp}:${totalTokens}`;
            if (seenHashes.has(hash)) continue;
            seenHashes.add(hash);

            messages.push({
              provider: msg.provider,
              model: msg.model,
              cost: msg.usage.cost?.total || 0,
              input,
              output,
              cacheRead,
              cacheWrite,
              timestamp,
            });
          }
        }
      } catch {
        // Skip malformed lines
      }
    }

    return sessionId ? { sessionId, messages } : null;
  } catch {
    return null;
  }
}

// =============================================================================
// Public API
// =============================================================================

export async function getUsageData(signal?: AbortSignal): Promise<UsageData> {
  const boundaries = computeTimeBoundaries();

  const sessionFiles = await getAllSessionFiles(signal);
  if (signal?.aborted) return emptyUsageData();

  const seenHashes = new Set<string>();
  const sessions: SessionMessages[] = [];

  for (const filePath of sessionFiles) {
    if (signal?.aborted) return emptyUsageData();
    const parsed = await parseSessionFile(filePath, seenHashes, signal);
    if (signal?.aborted) return emptyUsageData();
    if (!parsed) continue;
    sessions.push(parsed);
    await new Promise<void>((resolve) => setImmediate(resolve));
  }

  return aggregateSessionMessages(sessions, boundaries, boundaries.nowMs);
}
