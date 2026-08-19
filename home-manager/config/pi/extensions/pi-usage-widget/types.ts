/**
 * Shared type definitions for the usage widget refactor.
 *
 * Includes both the existing data-collection types (preserved from the original
 * index.ts) and the new config schema types for the settings system.
 */

// =============================================================================
// Existing data types (preserved from index.ts)
// =============================================================================

export interface TokenStats {
  total: number;
  input: number;
  output: number;
  cacheRead: number;
  cacheWrite: number;
}

export interface BaseStats {
  messages: number;
  cost: number;
  tokens: TokenStats;
}

export interface ModelStats extends BaseStats {
  sessions: Set<string>;
}

export interface ProviderStats extends BaseStats {
  sessions: Set<string>;
  models: Map<string, ModelStats>;
}

export interface TotalStats extends BaseStats {
  sessions: number;
}

export interface Insight {
  percent: number; // 0-100
  headline: string;
  advice: string;
}

export interface PeriodInsights {
  insights: Insight[];
}

export interface RawMessage {
  sessionId: string;
  timestamp: number;
  cost: number;
  input: number;
  cacheRead: number;
  cacheWrite: number;
}

export interface PeriodRawData {
  messages: RawMessage[];
  sessionCosts: Map<string, number>;
}

export interface GlobalSessionSpan {
  startMs: number;
  endMs: number;
}

export interface TimeFilteredStats {
  providers: Map<string, ProviderStats>;
  totals: TotalStats;
  insights: PeriodInsights;
}

export interface UsageData {
  lastHour: TimeFilteredStats;
  today: TimeFilteredStats;
  yesterday: TimeFilteredStats;
  thisWeek: TimeFilteredStats;
  lastWeek: TimeFilteredStats;
  thisMonth: TimeFilteredStats;
  allTime: TimeFilteredStats;
}

export type TimeScope =
  | "lastHour"
  | "today"
  | "yesterday"
  | "thisWeek"
  | "lastWeek"
  | "thisMonth"
  | "allTime";

export type DisplayMode =
  | "summary"
  | "compact"
  | "Per Model"
  | "expanded"
  | "hidden";

// Legacy display modes preserved for backward compatibility
export type LegacyDisplayMode =
  | "summary"
  | "compact"
  | "detailed-collapsed"
  | "detailed-expanded"
  | "hidden";

export type TabName = TimeScope;

export type ViewMode = "table" | "insights";

// =============================================================================
// New config schema types (Slice 1 — full schema, used progressively)
// =============================================================================

/**
 * Column visibility configuration for a single display mode.
 * Each boolean controls whether that column appears in the mode's output.
 */
export interface ModeColumnConfig {
  provider: boolean;
  model: boolean;
  sessions: boolean;
  msgs: boolean;
  cost: boolean;
  tokens: boolean;
  tokensIn: boolean;
  tokensOut: boolean;
  cache: boolean;
  /** Show/hide totals row for this mode */
  showTotals: boolean;
  /** Show/hide column header row for this mode */
  showHeaders: boolean;
  /** Show/hide header separator line for this mode */
  showHeaderLine: boolean;
  /** Show/hide footer separator line for this mode */
  showFooterLine: boolean;
  /** Show/hide the "Usage:" title prefix (summary mode only) */
  showTitle: boolean;
  /** Show/hide the "(scope)" label (summary mode only) */
  showScope: boolean;
  /** Show/hide the stat separator character between stat values (summary mode only) */
  showSeparator: boolean;
  /**
   * Column display order for data columns (sessions, msgs, cost, tokens,
   * tokensIn, tokensOut, cache). Name columns (provider, model) are not
   * included — they are always rendered first when applicable.
   */
  columnOrder: string[];
  /** Prefix Token In/Out values with ↑/↓ arrows in non-summary modes. */
  showInOutArrows: boolean;
}

/**
 * Per-element color override.
 * When non-null, the string is one of:
 *   - Theme fg role: "accent", "muted", "dim", "text", "border",
 *     "thinkingText", "error", "warning", "success", "info"
 *   - 16-color ANSI name: "black", "red", "green", "yellow", "blue",
 *     "magenta", "cyan", "white", "brightBlack", "brightRed", etc.
 *   - Custom hex code: "#rrggbb"
 * null means "inherit from parent level" (global → default scheme).
 */
export interface ColorOverrides {
  title: string | null;
  scope: string | null;
  // Column headers
  providerHeader: string | null;
  modelHeader: string | null;
  sessionsHeader: string | null;
  msgsHeader: string | null;
  costHeader: string | null;
  tokensHeader: string | null;
  tokensInHeader: string | null;
  tokensOutHeader: string | null;
  cacheHeader: string | null;
  // Column values
  providerValue: string | null;
  modelValue: string | null;
  sessionsValue: string | null;
  msgsValue: string | null;
  costValue: string | null;
  tokensValue: string | null;
  tokensInValue: string | null;
  tokensOutValue: string | null;
  cacheValue: string | null;
  // Separator lines
  headerLine: string | null;
  footerLine: string | null;
  // Structural
  separator: string | null;
  totalLabel: string | null;
}

/**
 * Widget placement within the TUI layout flow.
 */
export interface PlacementConfig {
  mode: "header" | "footer" | "detached";
  /** Horizontal padding chars (detached mode only) */
  paddingX: number;
  /** Vertical padding lines (detached mode only) */
  paddingY: number;
}

/**
 * Configuration for a single separator line (header or footer).
 */
export interface TableLineConfig {
  /** Show/hide the line */
  show: boolean;
  /** Color override (theme role, ANSI name, or hex; null = inherit) */
  color: string | null;
  /** Line character: "─", "═", "━", "···", or a custom single character */
  character: string;
}

/**
 * Named color scheme.
 */
export type ThemedPreset = "default";

/**
 * Top-level widget configuration.
 * Stored in ~/.pi/agent/config/pi-usage-widget-settings.json
 */
export interface UsageWidgetConfig {
  /** Global default display mode */
  defaultMode: DisplayMode;
  /** Global default time scope */
  defaultScope: TimeScope;
  /** Active color scheme */
  themedPreset: ThemedPreset;
  /** Per-mode color overrides (null entries inherit from the Pi theme) */
  perModeColorOverrides: Record<DisplayMode, ColorOverrides>;
  /** Widget placement */
  placement: PlacementConfig;
  /** Per-mode column configuration */
  modes: Record<DisplayMode, ModeColumnConfig>;
  /** Per-mode enabled state — determines if the mode appears in the cycle list */
  enabledModes: Record<DisplayMode, boolean>;
  /** Header separator line config */
  headerLine: TableLineConfig;
  /** Footer separator line config */
  footerLine: TableLineConfig;
}
