import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

// Expose the `repo-map` command (pkgs/repo-map) as a top-level tool.
export default function (pi: ExtensionAPI) {
  const z = pi.zod;

  pi.registerTool({
    name: "repo_map",
    label: "Repo Map",
    description: [
      "Ranked map of a repository: the most-referenced files with their key type and function signatures (Aider repo map, tree-sitter + PageRank).",
      "Call it FIRST when you explore an unfamiliar codebase or locate code for a task, before grep, glob, read or a scout agent.",
      "Pass `focus` files or `idents` from the task to rank related code higher. Then read only the files the map names.",
    ].join(" "),
    parameters: z.object({
      path: z.string().optional().describe("Repository directory. Default: the session cwd."),
      tokens: z.number().int().min(256).max(16384).optional().describe("Token budget for the map. Default: 2048."),
      focus: z.array(z.string()).optional().describe("Files, relative to path, to rank higher."),
      idents: z.array(z.string()).optional().describe("Identifiers to rank higher."),
    }),
    loadMode: "essential",
    approval: "read",
    async execute(_id, params, signal, _onUpdate, ctx) {
      const args = [params.path ?? ".", "--tokens", String(params.tokens ?? 2048)];
      for (const file of params.focus ?? []) args.push("--focus", file);
      for (const ident of params.idents ?? []) args.push("--ident", ident);

      const result = await pi.exec("repo-map", args, { cwd: ctx.cwd, signal, timeout: 300_000 });
      if (result.code !== 0) {
        const reason = result.stderr.trim().split("\n").at(-1) || `exit code ${result.code}`;
        throw new Error(`repo-map failed: ${reason}`);
      }
      return { content: [{ type: "text", text: result.stdout }] };
    },
  });
}
