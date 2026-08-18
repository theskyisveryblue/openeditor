---
name: openeditor-project-setup
description: Inspect an existing repo and generate OpenEditor onboarding config and lightweight runtime context, or work on OpenEditor-compatible app workflows. Use when Codex needs to infer web, Shopify, WordPress, static-generator, mobile, iOS, macOS, or multiplatform Apple projects; create or update `.logic-editor.json`, `oe-tests.json`, or `oe-swift.json`; plan minimal dependencies or MCP capabilities; generate OpenEditor spec/graph output; update preview/test/project detection behavior; build UI or data/API inventory frameworks; or change local desktop/agent integration features.
---

# OpenEditor Project Setup

## Quick Start

Use this skill to onboard an arbitrary repo into OpenEditor. The output is usually:

- a dependency-free generated context bundle under `.openeditor/context/`
- `.logic-editor.json`
- `oe-tests.json` with multistep runs for the key preview surfaces
- `oe-swift.json` for iOS or SwiftUI repos
- `openeditor.spec.json` or generated project spec output when the user asks for a spec, project catalog, UI contract, or graph-based app definition
- repository-owned flow documents under `.uidesign/flows/*.data-graph.json` when the repo provides enough evidence for meaningful architecture, delivery, data, access, or product flows
- focused changes to OpenEditor app workflows when the target repo is OpenEditor itself
- a UI inventory framework when the user needs to see screens, components, states, tokens, or source mappings
- a data/API inventory framework when the user needs to see APIs being used, APIs available, entities, schemas, or dependencies
- a short explanation of what was inferred vs. what still needs confirmation
- an explicit classification of `preview-ready` or `source-only` for iOS/Swift repos

When the repo signals are sufficient, generate the file contents directly.
When the environment has filesystem write access, create or update these files in the repo instead of stopping at a proposed JSON blob.
Only switch to a dry-run or example-output mode when the user explicitly asks for review-only output or the environment cannot write files.
Do not ask the user for the `.logic-editor.json` or `oe-swift.json` schema when the references in this skill already cover it.

Read only the references you need:

- Always read [references/project-config.md](references/project-config.md)
- Read [references/test-flows.md](references/test-flows.md) when defining flows, tests, or screenshot capture groups
- Read [references/project-detection.md](references/project-detection.md) when inferring framework, port, or run command
- Read [references/ios-config.md](references/ios-config.md) only for iOS or SwiftUI projects
- Read [references/spec-format.md](references/spec-format.md) when generating `openeditor.spec.json`, project spec catalogs, UI specs, or graph specs
- Read [references/data-graphs.md](references/data-graphs.md) when generating or updating documents displayed in the OpenEditor Flows pane
- Read [references/frameworks.md](references/frameworks.md) when building UI inventory, visual inspection, data inventory, API inventory, or source-mapping features
- Read [references/openeditor-app.md](references/openeditor-app.md) when changing OpenEditor itself, preview engines, project detection, desktop behavior, local agents, or app integration features
- Read [references/local-agent-setup.md](references/local-agent-setup.md) when detecting Codex or Claude, choosing a local agent, or providing a copy-and-paste setup fallback
- Read [references/runtime-context.md](references/runtime-context.md) when generating project context or planning runtime adapters
- Read [references/platforms.md](references/platforms.md) only for Shopify, WordPress, Apple, or static-generator projects
- Read [references/dependencies.md](references/dependencies.md) when a runtime capability is missing or installation is being considered
- Read [references/mcp-capabilities.md](references/mcp-capabilities.md) when MCP configuration or capabilities are relevant

## Public-Safe Documentation Rules

Write skill docs as if they may be shared outside the repo.

- keep guidance general and capability-oriented
- avoid proprietary architecture, algorithms, product strategy, vendor topology, private endpoint names, internal service names, or hidden implementation details
- prefer "local desktop shell", "backend service", "preview engine", "project registry", and "local agent bridge" over exact internal names unless the exact name is part of a public config format
- never include secrets, account IDs, bearer tokens, private domains, or raw deployment values
- use generic env placeholders such as `PLATFORM_ACCOUNT_ID` and `PLATFORM_API_TOKEN`
- keep exact file paths only when they are necessary for tests or direct repo maintenance; otherwise describe how to discover the relevant files with local search

## Workflow

### 1. Inspect the repo first

Look for the smallest high-signal set of inputs:

- `package.json`
- lockfiles such as `bun.lockb`, `bun.lock`, `package-lock.json`, or `pnpm-lock.yaml`
- framework folders such as `app/`, `pages/`, `src/`, `templates/`, `layout/`
- iOS signals such as `*.xcodeproj`, `*.xcworkspace`, and `*.swift`
- any existing `.logic-editor.json` or `oe-swift.json`

Run `scripts/generate-project-context.sh --repo .` when a reusable context handoff will help. The script is read-only apart from its generated `.openeditor/context/` output and has no third-party runtime dependency.

For graph-capable projects, preserve `uidesign.data-graph/v1` documents found either as direct `*.data-graph.json` files or embedded in `relatedArtifactDocuments`. Prefer explicit `extensions.focusPresets` group mappings. The Flows pane reads only declared project artifacts; it does not derive diagrams from App Preview routes or runtime state.

Do not invent support for frameworks that the references do not cover.

### 2. Infer the project type conservatively

Prefer the real parser defaults from the references over generic assumptions.

- `next` -> port `3000`, run command `npm run dev` or `bun dev` when Bun lockfiles are present
- `astro` -> port `4321`
- `expo` -> port `8081`, run command `npx expo start`
- `react-native` -> port `8081`, run command `npm start` or `bun start`
- Vite React -> port `5173`
- Shopify theme -> port `9292`, run command `openeditor-shopify-renderer --theme . --port 9292` when Connector provides the bundled renderer; Shopify CLI is not required for local OpenEditor previews
- iOS -> port `0`, empty `runCommand`, plus `oe-swift.json`
- Unknown web repo -> default to `type: "unknown"`, port `5173`, run command `npm run dev`

Detect WordPress, macOS, Apple multiplatform, Hugo, Jekyll, and Eleventy for context and planning, but keep generated application config within the supported types documented in `references/project-config.md`. Read `references/platforms.md` for compatibility mappings.

If the evidence is mixed, explain that uncertainty instead of pretending confidence.

### 3. Generate the smallest correct config

Rules:

- Keep `.logic-editor.json` minimal unless the repo clearly supports more
- Generate `oe-tests.json` when the repo has stable previewable surfaces
- Write or update the files on disk when the repo is writable
- Do not add speculative routes or URL-state variants just to look smart
- Include path params, query params, or URL-state variants when they create meaningfully different visible app states
- Use `requiredPorts` only when the preview depends on multiple local services and the repo clearly declares those ports
- When using `requiredPorts`, always include the preview/UI port
- If route discovery is weak, emit a single home route:
  - `{ "path": "/", "label": "Home" }`
- Preserve existing config when updating; merge carefully instead of replacing unrelated fields
- Do not invent unsupported keys
- For a repository with multiple independently runnable apps, use the compound-target shape from `references/project-config.md`; keep the existing top-level runtime fields as the backward-compatible active target

### 3a. Keep preview config in sync when the app changes

The config files are the single source of truth OpenEditor uses to render previews. When app code changes the preview surface, update the config so previews and tests never go stale:

- add, rename, or remove routes, paths, and query states in `.logic-editor.json` as they change in code
- update `oe-tests.json` flows when the covered routes, steps, or URLs change
- refresh `port`, `requiredPorts`, and `runCommand` when the local run layout changes
- for iOS/SwiftUI, keep `oe-swift.json` accurate: update `views` as Swift view files are added, renamed, or removed, and keep `scheme` and `project` pointing at the real targets (see section 4)
- after a meaningful edit pass, re-check the config against the current route structure instead of assuming it is still current

This skill only manages OpenEditor config and preview surfaces. It never dictates how app code should be written, which framework or router to use, or how source files should be structured. Do not let config generation leak into code style or architecture suggestions unless the user explicitly asks. If the config workflow and app code conflict, keep app code authoritative and adjust the config to match.

### 4. Only generate `oe-swift.json` for real iOS projects

When the repo is SwiftUI or Xcode-based:

- infer `scheme` from the `.xcodeproj` or `.xcworkspace` name when possible
- when multiple Xcode projects, workspaces, or app schemes exist, inspect their schemes and bundle/product evidence; do not select the first path alphabetically
- represent independently runnable Apple apps with `targets`, and choose the active top-level target from explicit repo evidence such as an existing config, documented primary app, matching bundle name, or runnable shared scheme
- do not emit a `simulator` field: available simulator devices differ per machine, and OpenEditor auto-selects and boots an available simulator
- infer views from obvious `*View.swift` files
- keep view entries simple unless the repo provides stronger signals
- do not fabricate bundle IDs, deep links, or accessibility tap metadata unless the repo exposes them
- if the repo has a real `.xcodeproj` or `.xcworkspace`, include the `project` path in `oe-swift.json`
- if the repo is only a Swift package (`Package.swift`) with no installable `.xcodeproj` or `.xcworkspace`, treat the output as `source-only`
- for `source-only` Swift packages, generate the conservative `oe-swift.json` scaffold if useful, but explicitly say simulator previews are unavailable until `project` points at a host app / installable Xcode target
- do not present a Swift package-only repo as preview-ready just because views and a scheme were inferred

### 5. Explain assumptions explicitly

After the config output, include a short explanation covering:

- detected framework or platform
- chosen port and run command
- whether routes were inferred or defaulted
- whether params or state variants were included and why
- whether `requiredPorts` were inferred and why
- whether `oe-swift.json` was generated and why
- whether the result is preview-ready or only source-only
- which fields should be manually confirmed

### 6. Generate specs when requested

When the user asks for a spec format, app spec, UI spec, graph spec, or project catalog:

- use the graph-first model from `references/spec-format.md`
- separate term definitions, markup definitions, logic/data definitions, and logic snippet definitions
- preserve traceability with graph edges instead of flattening everything into prose
- generate specs for every discovered `.logic-editor.json` project when the user asks for all projects
- use `node scripts/generate-openeditor-specs.mjs` for repo-wide generation when available
- test generation locally before reporting success
- keep raw secrets out of spec files; use env references such as `CLOUDFLARE_ACCOUNT_ID` and `CLOUDFLARE_API_TOKEN`
- do not push generated specs or private deployment information unless the user explicitly asks

### 6a. Generate repository-owned flow documents

When onboarding a project with enough source evidence for a meaningful system or process graph:

- read `references/data-graphs.md`
- preserve and update existing `*.data-graph.json` documents instead of replacing them
- otherwise write one or more focused documents under `.uidesign/flows/`
- derive nodes and relationships from repository evidence such as workspace boundaries, imports, API schemas, infrastructure declarations, auth policies, deployment workflows, and project documentation
- record source evidence in node or edge extensions where practical
- use `extensions.focusPresets` for user-facing tabs such as `Main flow`, `Delivery`, `Security`, or `All`; these names are project-defined
- validate every generated document with `node scripts/validate-data-graph.mjs <path>` from this skill directory
- do not use `.logic-editor.json` routes alone as an architecture model
- do not couple a flow document to the currently selected App Preview route, pane, or runtime process
- do not generate a speculative graph when the evidence cannot support at least two meaningful entities and one relationship

The generated file is a normal, editable project artifact. Regeneration is an explicit setup/update action, never an editor-runtime fallback.

Use `openeditor flows check --root .` for a read-only inventory. Use `openeditor flows refresh --root .` to preview the exact regeneration prompt. Only `openeditor flows refresh --root . --apply` launches Codex with project-scoped workspace-write access.

### 7. Build UI and data/API frameworks when requested

When the user asks to look at the UI, inspect the UI, map screens, or understand APIs/data:

- read `references/frameworks.md`
- model UI as surfaces, states, components, tokens, screenshots, DOM snapshots, and source mappings
- model data as observed API usage, declared API surfaces, possible API surfaces, entities, schemas, auth requirements, and source mappings
- classify evidence as `observed`, `declared`, `inferred`, or `possible`
- redact sensitive values and use env references instead of raw secrets
- prefer a general framework that works across React, Next, Astro, Shopify, iOS, Expo, React Native, and static projects
- when source markup can be edited, suggest sparse generic tags such as `data-ui-component`, `data-ui-family`, `data-ui-kind`, `data-ui-part`, `data-ui-state`, `data-ui-variant`, and `data-ui-source` to map rendered UI back to source; keep tags opt-in and non-invasive

### 8. Work on OpenEditor itself when requested

When the current repo is OpenEditor or an OpenEditor-compatible app workspace:

- read `references/openeditor-app.md`
- keep changes inside the existing app architecture
- update focused tests for preview engines, project detection, canvas behavior, or skill behavior when touched
- keep local agent work desktop-only unless the user explicitly asks for a web/server variant
- use an embedded local agent bridge for interactive desktop UX; use batch automation only for CI or one-shot jobs

### 9. Prefer generation over schema questions

If the repo is a supported type and the references here cover the config format:

- create or update the files directly when write access is available
- otherwise generate the file contents directly
- use conservative defaults when some fields are weakly signaled
- ask follow-up questions only when a missing field would make the config invalid or misleading

Do not stop with "I need the schema" for normal React, Next, Astro, Expo, React Native, Shopify, or iOS repos.

### 10. Keep agent-assisted onboarding automatic but honest

When OpenEditor can use a local Codex or Claude client:

- use the detector in `scripts/detect-local-agents.sh`
- distinguish installed, authenticated, preferred, and unknown states
- never claim the user has a paid subscription based only on a binary or login
- automatically use the only authenticated agent
- reuse a saved local preference when both are authenticated
- otherwise ask one concise agent-choice question
- prefer the local app terminal or agent bridge; show the copy-and-paste fallback when unavailable
- avoid persistent background agent work after setup finishes

### 11. Plan dependencies without making discovery heavy

When a preview capability is missing:

- read `references/dependencies.md`
- separate source inspection from managed runtime needs
- prefer existing repo commands, lockfiles, native tools, external development URLs, and fallbacks
- classify missing capabilities as required, recommended, or optional
- never install during context generation
- request explicit approval before installing a new project-local, user-local, system, container, or MCP dependency
- regenerate context after an approved installation

Do not require Docker, Node, PHP, Ruby, Shopify CLI, WordPress CLI, XcodeBuildMCP, or another platform tool merely to inspect source.

### 12. Treat MCP servers as optional capability providers

When MCP is relevant:

- read `references/mcp-capabilities.md`
- detect repository-local MCP configuration locations without copying their contents
- ask the active client which tools and resources are actually available
- map servers to capabilities and record a native or local fallback where practical
- never claim a configured server is connected until its tools are visible
- never install or authorize an MCP server without explicit user approval

Essential onboarding and preview operations should not depend exclusively on an MCP server when a practical built-in or native fallback exists.

## Output Rules

When the user asks for file contents, or when the environment cannot write files, prefer this structure:

```text
.logic-editor.json
```json
{ ... }
```

oe-tests.json
```json
{ ... }
```

oe-swift.json
```json
{ ... }
```

openeditor.spec.json
```json
{ ... }
```

Notes
- ...
```

If the project is not iOS, omit `oe-swift.json`. If the user did not ask for a spec, omit `openeditor.spec.json`.

If there is already a config file, show the updated file content instead of a from-scratch template.

If the environment can write files and the user asked to onboard the repo, the preferred behavior is:

- inspect the repo
- create or update `.logic-editor.json`
- create or update `oe-tests.json` when applicable
- create or update `oe-swift.json` only for real iOS/SwiftUI projects
- then report what was written and what still needs confirmation
