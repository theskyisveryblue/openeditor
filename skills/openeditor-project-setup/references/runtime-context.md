# Runtime Context Bundle

Use this reference when generating project context, planning runtime adapters, or deciding which optional tools are useful.

## Generate context first

Run:

```sh
skills/openeditor-project-setup/scripts/generate-project-context.sh --repo .
```

The script uses POSIX shell and standard system utilities. It must not install packages, start services, contact remote systems, or read credential values.

By default it writes disposable files under `.openeditor/context/`:

| File | Purpose |
| --- | --- |
| `project-context.json` | Stable, compact project classification |
| `signals.tsv` | Evidence used for classification |
| `tools.tsv` | Available and missing local commands |
| `dependencies.tsv` | Required, recommended, and optional capabilities |
| `mcp.tsv` | MCP configuration locations and useful capability classes |
| `platforms.tsv` | Primary and secondary runtimes in mixed workspaces |
| `surfaces.txt` | Candidate routes, templates, views, and content surfaces |
| `files.txt` | Bounded high-signal file list |
| `graphs.tsv` | Direct and embedded `uidesign.data-graph/v1` artifact locations |
| `graph-focus.tsv` | Explicit focus metadata or the legacy group-order fallback in use |
| `summary.md` | Human-readable handoff |

Treat these files as generated cache. Do not commit them unless the user explicitly wants a reproducible context snapshot.

## Field contract

`project-context.json` separates current compatibility from future platform support:

- `platform`: the actual detected family, such as `shopify`, `wordpress`, `apple`, or `static`
- `variant`: the detected subtype, such as `block-theme`, `classic-theme`, `multiplatform`, `hugo`, or `eleventy`
- `compatibilityType`: a currently valid `.logic-editor.json` type
- `confidence`: `high`, `medium`, or `low`
- `readiness`: whether the repo can be previewed now, needs an external runtime, needs tools, or is source-only
- `runtimeLayout`: `single-runtime` or `multi-runtime`
- `graphArtifactCount`: number of graph artifacts found without copying their contents

Do not copy future-only `platform` or `variant` values into `.logic-editor.json` fields that do not support them yet.

## Evidence rules

- Prefer file presence and explicit config over guesses.
- Treat an existing `.logic-editor.json` type as the primary runtime unless contradictory evidence makes it invalid.
- Record nested Apple, WordPress, Shopify, or other runtimes as secondary instead of letting them replace the configured root runtime.
- Exclude fixtures, tests, dependencies, caches, and build output when determining runtime ownership.
- Record evidence without copying file contents that may contain secrets.
- Bound recursive scans and prune generated, dependency, cache, and VCS directories.
- Store project-relative paths where possible.
- Treat embedded `relatedArtifactDocuments` as virtual project files and retain their artifact keys.
- Prefer explicit `extensions.focusPresets` group mappings; use group-order focus only as a compatibility fallback.
- Never scan `.env`, credentials, keychains, browser profiles, or home-directory MCP configuration contents.
- Detect MCP configuration locations, not tokens or command arguments embedded in them.

## Runtime adapter handoff

The context bundle is neutral input for future runtime adapters. An adapter may use:

- classification and variant
- available commands
- candidate surfaces
- readiness and missing capabilities
- MCP capability availability

The adapter remains responsible for deterministic launch, health checks, capture, input, reload, and shutdown. A skill or MCP server must not be the only implementation of essential preview behavior.
