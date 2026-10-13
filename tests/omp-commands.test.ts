import { describe, expect, test } from "bun:test";
import type { ExtensionAPI, ExtensionContext } from "@oh-my-pi/pi-coding-agent";
import type { AutocompleteItem, AutocompleteProvider } from "@oh-my-pi/pi-tui";
import minimalCommands from "../home-manager/config/omp/minimal-commands";

type ProviderFactory = (current: AutocompleteProvider) => AutocompleteProvider;
type StartHandler = (event: unknown, ctx: ExtensionContext) => void;
type InputHandler = (event: { source: "interactive"; text: string }, ctx: ExtensionContext) => { handled?: boolean } | void;

function commandFixture(names: string[], prefix = "/") {
  let factory: ProviderFactory;
  let start: StartHandler;
  let input: InputHandler;
  const ctx = {
    mode: "tui",
    agent: { kind: "main" },
    ui: {
      addAutocompleteProvider(next: ProviderFactory) { factory = next; },
      notify() {},
    },
  } as unknown as ExtensionContext;
  minimalCommands({
    on(event: string, handler: StartHandler | InputHandler) {
      if (event === "session_start") start = handler as StartHandler;
      if (event === "input") input = handler as InputHandler;
    },
  } as unknown as ExtensionAPI);
  start!(undefined, ctx);
  const suggestions = {
    prefix,
    items: names.map(value => ({ value, label: value })),
  };
  const provider = factory!({
    async getSuggestions(_lines, _line, _col, _signal, onPartial) {
      onPartial?.(suggestions);
      return suggestions;
    },
    trySyncSlashCompletion() { return suggestions; },
    getInlineHint() { return "<arguments>"; },
    applyCompletion() { throw new Error("These tests do not accept completion items"); },
  });
  return {
    provider,
    submit(text: string) { return input!({ source: "interactive", text }, ctx); },
  };
}

describe("OMP command allowlist", () => {
  test("new commands and record prototype names remain hidden and blocked", async () => {
    const { provider, submit } = commandFixture(["model", "upstream-new-command", "constructor", "toString"]);
    const partials: AutocompleteItem[][] = [];
    const result = await provider.getSuggestions(["/"], 0, 1, undefined, next => partials.push(next.items));
    expect(result?.items.map(item => item.value)).toEqual(["model"]);
    expect(partials.map(items => items.map(item => item.value))).toEqual([["model"]]);
    expect(provider.trySyncSlashCompletion?.("/")?.items.map(item => item.value)).toEqual(["model"]);
    for (const name of ["upstream-new-command", "constructor", "toString"]) {
      expect(submit(`/${name}`)).toEqual({ handled: true });
    }
  });

  test("an exact disabled command cannot expand into an enabled command", async () => {
    const { provider, submit } = commandFixture(["modelpreset", "model"], "  /modelpreset");
    expect(await provider.getSuggestions(["  /modelpreset"], 0, 14)).toBeNull();
    expect(provider.trySyncSlashCompletion?.("  /modelpreset")).toBeNull();
    expect(submit("  /modelpreset")).toEqual({ handled: true });
  });

  test("unknown command tokens cannot select unrelated enabled commands", async () => {
    const { provider, submit } = commandFixture(["new", "handoff"], "/constructor");
    expect(await provider.getSuggestions(["/constructor"], 0, 12)).toBeNull();
    expect(provider.trySyncSlashCompletion?.("/constructor")).toBeNull();
    expect(submit("/constructor")).toEqual({ handled: true });
  });

  test("permitted prefixes still complete without exposing disabled candidates", async () => {
    const { provider } = commandFixture(["model", "modelpreset"], "/mo");
    expect((await provider.getSuggestions(["/mo"], 0, 3))?.items.map(item => item.value)).toEqual(["model"]);
    expect(provider.trySyncSlashCompletion?.("/mo")?.items.map(item => item.value)).toEqual(["model"]);
  });

  test("aliases and builtin colon arguments do not permit prompt namespaces", () => {
    const { submit } = commandFixture([]);
    for (const text of ["/models", "/providers", "/q", "/session:info", "/grill-me discuss the design"]) {
      expect(submit(text)).toBeUndefined();
    }
    for (const text of ["/review", "/grill-me:new-command", "/skill:review", "/plan:/tmp/plan.md"]) {
      expect(submit(text)).toEqual({ handled: true });
    }
    expect(submit("/tmp/source.ts")).toBeUndefined();
  });

  test("disabled argument menus and hints cannot leak through completion", async () => {
    const { provider } = commandFixture(["on", "off"], "");
    expect(await provider.getSuggestions(["/computer "], 0, 10)).toBeNull();
    expect(provider.getInlineHint?.(["/computer "], 0, 10)).toBeNull();
  });
});
