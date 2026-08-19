/**
 * Pure formatting functions extracted from index.ts.
 * No TUI or Theme dependency — these are simple data-in, string-out formatters.
 */

import type { TimeScope } from "./types.js";

// =============================================================================
// Public formatting API
// =============================================================================

export function formatCost(cost: number): string {
  if (cost === 0) return "-";
  if (cost < 0.01) return `$${cost.toFixed(4)}`;
  if (cost < 1) return `$${cost.toFixed(2)}`;
  if (cost < 10) return `$${cost.toFixed(2)}`;
  if (cost < 100) return `$${cost.toFixed(1)}`;
  return `$${Math.round(cost)}`;
}

export function formatTokens(count: number): string {
  if (count === 0) return "-";
  if (count < 1000) return count.toString();
  if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
  if (count < 1000000) return `${Math.round(count / 1000)}k`;
  if (count < 10000000) return `${(count / 1000000).toFixed(1)}M`;
  return `${Math.round(count / 1000000)}M`;
}

export function formatNumber(n: number): string {
  if (n === 0) return "-";
  return n.toLocaleString();
}

export function formatCostFixed3(cost: number): string {
  if (cost === 0) return "-";
  return `$${cost.toFixed(3)}`;
}

export function formatScopeLabel(scope: TimeScope): string {
  switch (scope) {
    case "lastHour":
      return "Last Hour";
    case "today":
      return "Today";
    case "yesterday":
      return "Yesterday";
    case "thisWeek":
      return "This Week";
    case "lastWeek":
      return "Last Week";
    case "thisMonth":
      return "This Month";
    case "allTime":
      return "All Time";
  }
}

export function formatThresholdTokens(n: number): string {
  if (n >= 1_000_000) return `${n / 1_000_000}M`;
  if (n >= 1_000) return `${n / 1_000}k`;
  return String(n);
}

export function formatInsightPercent(p: number): string {
  if (p >= 10) return `${Math.round(p)}%`;
  return `${Math.round(p * 10) / 10}%`;
}
