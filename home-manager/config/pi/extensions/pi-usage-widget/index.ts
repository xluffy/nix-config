/**
 * /usage — Usage statistics dashboard, shown on demand.
 *
 * Parses Pi session files and shows a per-provider and per-model table
 * with cost and token breakdowns. Press Tab to change the time period,
 * v to toggle insights, q to close.
 *
 * Derived from index.ts in the pi-usage-widget project by Cullen Botha.
 * Copyright (c) 2026 Cullen Botha. MIT license. See the LICENSE file.
 *
 * Local change: the upstream widget, shortcuts, and settings menu are
 * removed. Only the /usage dashboard command remains.
 */

import type {
  ExtensionAPI,
  ExtensionCommandContext,
} from "@earendil-works/pi-coding-agent";
import { DynamicBorder } from "@earendil-works/pi-coding-agent";
import { CancellableLoader, Container, Spacer, truncateToWidth } from "@earendil-works/pi-tui";
import { getUsageData } from "./data-collection.js";
import { UsageComponent } from "./usage-modal.js";
import type { UsageData } from "./types.js";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("usage", {
    description: "Show usage statistics dashboard",
    handler: async (_args: string, ctx: ExtensionCommandContext) => {
      if (!ctx.hasUI) return;

      const data = await ctx.ui.custom<UsageData | null>(
        (tui, theme, _kb, done) => {
          const loader = new CancellableLoader(
            tui,
            (s: string) => theme.fg("accent", s),
            (s: string) => theme.fg("muted", s),
            "Loading Usage...",
          );
          let finished = false;
          const finish = (value: UsageData | null) => {
            if (finished) return;
            finished = true;
            loader.dispose();
            done(value);
          };

          loader.onAbort = () => finish(null);

          getUsageData(loader.signal)
            .then((d) => finish(d))
            .catch(() => finish(null));

          return loader;
        },
      );

      if (!data) return;

      await ctx.ui.custom<void>((tui, theme, _kb, done) => {
        const container = new Container();
        container.addChild(new Spacer(1));
        container.addChild(
          new DynamicBorder((s: string) => theme.fg("border", s)),
        );
        container.addChild(new Spacer(1));

        const usage = new UsageComponent(
          theme,
          data,
          () => tui.requestRender(),
          () => done(),
        );

        return {
          render: (w: number) => {
            const borderLines = container
              .render(w)
              .map((l) => truncateToWidth(l, w));
            const usageLines = usage.render(w);
            const bottomBorder = theme.fg("border", "\u2500".repeat(w));
            return [...borderLines, ...usageLines, "", bottomBorder].map((l) =>
              truncateToWidth(l, w),
            );
          },
          invalidate: () => container.invalidate(),
          handleInput: (input: string) => usage.handleInput(input),
          dispose: () => {},
        };
      });
    },
  });
}
