import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";
import type { AutocompleteItem, AutocompleteProvider } from "@oh-my-pi/pi-tui";

const enabledCommands: Record<string, "builtin" | "prompt"> = {
  login: "builtin",
  logout: "builtin",
  model: "builtin",
  models: "builtin",
  switch: "builtin",
  effort: "builtin",
  settings: "builtin",
  setup: "builtin",
  providers: "builtin",
  hotkeys: "builtin",
  quit: "builtin",
  q: "builtin",
  exit: "builtin",
  restart: "builtin",
  new: "builtin",
  clear: "builtin",
  resume: "builtin",
  session: "builtin",
  pin: "builtin",
  handoff: "builtin",
  export: "builtin",
  todo: "builtin",
  jobs: "builtin",
  usage: "builtin",
  stats: "builtin",
  "audit-me": "prompt",
  "git-ci": "prompt",
  "grill-me": "prompt",
  "spec-quick": "prompt",
  "spec-workflow": "prompt",
};

interface Suggestions {
  items: AutocompleteItem[];
  prefix: string;
}

function commandName(text: string): string | undefined {
  const name = /^\/([^\s:]+)/.exec(text.trimStart())?.[1];
  return name?.includes("/") ? undefined : name;
}

function isEnabledCommand(text: string, name: string): boolean {
  const kind = enabledCommands[name];
  return kind === "builtin" || (kind === "prompt" && text.trimStart()[name.length + 1] !== ":");
}

function blockedCommandAtCursor(lines: string[], cursorLine: number, cursorCol: number): boolean {
  for (let line = 0; line < cursorLine; line++) {
    if ((lines[line] ?? "").trim()) return false;
  }
  const text = (lines[cursorLine] ?? "").slice(0, cursorCol).trimStart();
  const name = commandName(text);
  return name !== undefined && !isEnabledCommand(text, name) && /[\s:]/.test(text.slice(1));
}

function filterSuggestions(suggestions: Suggestions | null): Suggestions | null {
  if (!suggestions || !/^\/[^\s/]*$/.test(suggestions.prefix.trimStart())) return suggestions;
  const prefix = suggestions.prefix.trimStart();
  const name = commandName(prefix);
  // An exact disabled command must not expand to a different enabled command.
  if (
    name !== undefined &&
    !isEnabledCommand(prefix, name) &&
    suggestions.items.some(item => item.value === prefix.slice(1))
  ) {
    return null;
  }
  const query = prefix.slice(1).toLowerCase();
  const items = suggestions.items.filter(item =>
    Object.hasOwn(enabledCommands, item.value) && item.value.toLowerCase().startsWith(query));
  return items.length > 0 ? { ...suggestions, items } : null;
}

function filterCommands(current: AutocompleteProvider): AutocompleteProvider {
  return {
    async getSuggestions(lines, cursorLine, cursorCol, signal, onPartial) {
      if (blockedCommandAtCursor(lines, cursorLine, cursorCol)) return null;
      return filterSuggestions(await current.getSuggestions(
        lines,
        cursorLine,
        cursorCol,
        signal,
        onPartial ? suggestions => {
          const filtered = filterSuggestions(suggestions);
          onPartial(filtered ?? { items: [], prefix: suggestions.prefix });
        } : undefined,
      ));
    },
    applyCompletion: current.applyCompletion.bind(current),
    getInlineHint(lines, cursorLine, cursorCol) {
      if (blockedCommandAtCursor(lines, cursorLine, cursorCol)) return null;
      return current.getInlineHint?.(lines, cursorLine, cursorCol) ?? null;
    },
    // The editor also uses this path before Enter and while the menu is open.
    trySyncSlashCompletion(textBeforeCursor) {
      return filterSuggestions(current.trySyncSlashCompletion?.(textBeforeCursor) ?? null);
    },
    trySyncInlineReplace: current.trySyncInlineReplace?.bind(current),
    getForceFileSuggestions: current.getForceFileSuggestions?.bind(current),
    shouldTriggerFileCompletion: current.shouldTriggerFileCompletion?.bind(current),
  };
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode === "tui" && ctx.agent.kind === "main") {
      ctx.ui.addAutocompleteProvider(filterCommands);
    }
  });

  // Enter and Ctrl+Enter run input handlers before built-in command dispatch.
  pi.on("input", (event, ctx) => {
    if (event.source !== "interactive" || ctx.mode !== "tui") return;
    const name = commandName(event.text);
    if (name === undefined || isEnabledCommand(event.text, name)) return;
    ctx.ui.notify(`/${name} is disabled by the minimal command menu.`, "warning");
    return { handled: true };
  });
}
