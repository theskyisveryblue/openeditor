---
name: openeditor-project-setup
description: Inspect an existing repo and generate OpenEditor onboarding config for it, or work on OpenEditor-compatible app workflows. Use when Codex needs to make a project OpenEditor-compatible by inferring framework or platform from the file tree, creating or updating `.logic-editor.json`, generating `oe-tests.json`, creating `oe-swift.json` for iOS or SwiftUI projects, generating OpenEditor spec/graph output, updating preview/test/project detection behavior, building UI or data/API inventory frameworks, or changing local desktop/agent integration features.
---

# OpenEditor Project Setup

## Quick Start

Use this skill to onboard an arbitrary repo into OpenEditor. The output is usually:

- `.logic-editor.json`
- `oe-tests.json` with multistep runs for the key preview surfaces
- `oe-swift.json` for iOS or SwiftUI repos
- `openeditor.spec.json` or generated project spec output when the user asks for a spec, project catalog, UI contract, or graph-based app definition
- focused changes to OpenEditor app workflows when the target repo is OpenEditor itself
- a UI inventory framework when the user needs to see screens, components, states, tokens, or source mappings
- optional source-tagging guidance when the user wants the editor to identify components, screens, states, variants, or source ownership from app code
- a data/API inventory framework when the user needs to see APIs being used, APIs available, entities, schemas, or dependencies
- a short explanation of what was inferred vs. what still needs confirmation
- an explicit classification of `preview-ready` or `source-only` for iOS/Swift repos

When the repo signals are sufficient, generate the file contents directly.
When the environment has filesystem write access, create or update these files in the repo instead of stopping at a proposed JSON blob.
Only switch to a dry-run or example-output mode when the user explicitly asks for review-only output or the environment cannot write files.
Do not ask the user for the `.logic-editor.json` or `oe-swift.json` schema when the references in this skill already cover it.

Read only the references you need:

- Always read [references/project-config.md](references/project-config.md)
- Read [references/project-detection.md](references/project-detection.md) when inferring framework, port, or run command
- Read [references/ios-config.md](references/ios-config.md) only for iOS or SwiftUI projects
- Read [references/spec-format.md](references/spec-format.md) when generating `openeditor.spec.json`, project spec catalogs, UI specs, or graph specs
- Read [references/frameworks.md](references/frameworks.md) when building UI inventory, visual inspection, data inventory, API inventory, or source-mapping features
- Read [references/openeditor-app.md](references/openeditor-app.md) when changing OpenEditor itself, preview engines, project detection, desktop behavior, local agents, or app integration features

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

Do not invent support for frameworks that the references do not cover.

### 2. Infer the project type conservatively

Prefer the real parser defaults from the references over generic assumptions.

- `next` -> port `3000`, run command `npm run dev` or `bun dev` when Bun lockfiles are present
- `astro` -> port `4321`
- `expo` -> port `8081`, run command `npx expo start`
- `react-native` -> port `8081`, run command `npm start` or `bun start`
- Vite React -> port `5173`
- Shopify theme -> port `9292`, run command `shopify theme dev`
- iOS -> port `0`, empty `runCommand`, plus `oe-swift.json`
- Unknown web repo -> default to `type: "unknown"`, port `5173`, run command `npm run dev`

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

### 4. Only generate `oe-swift.json` for real iOS projects

When the repo is SwiftUI or Xcode-based:

- infer `scheme` from the `.xcodeproj` or `.xcworkspace` name when possible
- default simulator to `iPhone 16 Pro`
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

### 7. Build UI and data/API frameworks when requested

When the user asks to look at the UI, inspect the UI, map screens, or understand APIs/data:

- read `references/frameworks.md`
- model UI as surfaces, states, components, tokens, screenshots, DOM snapshots, and source mappings
- when source markup can be changed, recommend generic `data-ui-*` attributes to mark stable components, parts, states, variants, surfaces, platforms, and source ownership
- model data as observed API usage, declared API surfaces, possible API surfaces, entities, schemas, auth requirements, and source mappings
- classify evidence as `observed`, `declared`, `inferred`, or `possible`
- redact sensitive values and use env references instead of raw secrets
- prefer a general framework that works across React, Next, Astro, Shopify, iOS, Expo, React Native, and static projects

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
