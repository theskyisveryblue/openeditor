# Project Detection Heuristics

Use these heuristics when inferring OpenEditor config from a repo.

## Highest-confidence signals

1. Existing `.logic-editor.json`
2. Existing `oe-swift.json`
3. `templates/` plus `layout/` -> Shopify
4. WordPress theme headers plus PHP or block templates
5. `.xcodeproj` or `.xcworkspace`
6. static-generator config
7. `package.json` dependencies

## Dependency-based detection

These are the current parser-aligned defaults:

| Signal | `type` | `port` | `runCommand` |
| --- | --- | --- | --- |
| `next` dep | `next` | `3000` | `npm run dev` or `bun dev` with Bun lockfiles |
| `astro` dep | `astro` | `4321` | `npm run dev` or `bun dev` |
| `@remix-run/react` dep | `react` | `3000` | `npm run dev` or `bun dev` |
| `expo` dep | `expo` | `8081` | `npx expo start` |
| `react-native` dep | `react-native` | `8081` | `npm start` or `bun start` |
| `vite` or `@vitejs/plugin-react` | `react` | `5173` | `npm run dev` or `bun dev` |
| `react` only | `react` | `3000` | `npm run dev` or `bun dev` |

## Bun preference

If the repo has `bun.lockb` or `bun.lock`, prefer Bun-style commands:

- `npm run dev` -> `bun dev`
- `npm start` -> `bun start`

Do not rewrite `npx expo start` to Bun.

## Shopify detection

If the repo has both:

- `templates/`
- `layout/`

then use:

```json
{
  "type": "shopify",
  "port": 9292,
  "runCommand": "openeditor-shopify-renderer --theme . --port 9292"
}
```

The renderer is bundled with OpenEditor Connector and uses JavaScript Liquid
rendering with simulated commerce objects. It can also read captured or
AI-generated store datasets from OpenEditor application storage. Do not install
Shopify CLI merely to preview a theme in OpenEditor.

## iOS detection

If the repo has either:

- `oe-swift.json`
- `.xcodeproj`
- `.xcworkspace`

then treat it as `ios`.

For iOS:

- `port` should be `0`
- `runCommand` should be `""`
- generate `oe-swift.json`

Record macOS, Catalyst, or multiplatform evidence in generated runtime context. Do not add future-only values to the current `.logic-editor.json` schema.

## Native Android detection

Treat a repository with a Gradle wrapper plus `settings.gradle` or
`settings.gradle.kts` as `android`. Use port `0`, an empty top-level
`runCommand`, and a single conservative Home route unless stronger route
evidence exists. Classify native Android as `source-only` until OpenEditor has
an attached Android preview host; do not fabricate browser frames or claim an
emulator is available merely because Gradle can build the source.

## WordPress and static generators

Read `platforms.md` for classic, block, hybrid, and child WordPress theme detection and for Hugo, Jekyll, Eleventy, and plain-static signals.

WordPress currently maps to `type: "unknown"` in `.logic-editor.json`. Preserve the richer `platform` and `variant` only in generated context until the application parser supports them.

## Route inference guidance

Use only strong route signals:

- Next `app/` or `pages/`
- Expo Router `app/`
- obvious router files with concrete paths
- Shopify template names

If strong route inference is not possible, default to one route:

```json
[{ "path": "/", "label": "Home" }]
```
