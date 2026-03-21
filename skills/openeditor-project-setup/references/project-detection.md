# Project Detection Heuristics

Use these heuristics when inferring OpenEditor config from a repo.

## Highest-confidence signals

1. Existing `.logic-editor.json`
2. Existing `oe-swift.json`
3. `templates/` plus `layout/` -> Shopify
4. `package.json` dependencies
5. `.xcodeproj` or `.xcworkspace`

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
  "runCommand": "shopify theme dev"
}
```

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
