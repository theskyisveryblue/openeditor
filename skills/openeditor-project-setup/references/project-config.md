# OpenEditor Project Config

Use this file for the canonical `.logic-editor.json` shape.

## Minimal shape

```json
{
  "name": "my-project",
  "type": "react",
  "port": 5173,
  "requiredPorts": [5173],
  "runCommand": "bun dev",
  "routes": [
    { "path": "/", "label": "Home" }
  ]
}
```

## Canonical fields

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `name` | `string` | yes | Display name in OpenEditor |
| `type` | `string` | yes | One of the supported project types |
| `port` | `number` | yes | Expected local dev server port |
| `requiredPorts` | `number[]` | no | Additional ports that must be alive for multi-service local stacks |
| `runCommand` | `string` | usually | Empty string is valid for mobile or iOS projects |
| `routes` | `array` | yes | At least one route |
| `platform` | `string` | no | Useful for mobile projects |
| `resolutions` | `number[]` | no | Widths for generated preview frames |
| `autoStart` | `boolean` | no | Whether OpenEditor should auto-start the local preview |
| `automation` | `object` | no | Declarative, allowlisted local automation; never accepts shell commands |
| `mobile` | `object` | no | Mobile metadata |
| `ios` | `object` | no | iOS metadata when embedded inside `.logic-editor.json` |
| `integrations` | `object` | no | Optional integration metadata |
| `product` | `object` | no | Stable `{ id, label }` shared by related targets or repositories |
| `activeTargetId` | `string` | no | Target selected when no explicit UI or URL selection exists |
| `targets` | `array` | no | Independently runnable app targets in a compound repository |

## Compound projects and products

Use `targets` when one repository contains multiple independently runnable apps or schemes. Keep the top-level runtime fields as the backward-compatible active target.

```json
{
  "name": "app-family",
  "activeTargetId": "client-ios",
  "type": "ios",
  "port": 0,
  "runCommand": "",
  "routes": [{ "path": "/", "label": "Client" }],
  "ios": {
    "project": "ios/AppFamily.xcodeproj",
    "scheme": "Client"
  },
  "targets": [
    {
      "id": "client-ios",
      "label": "Client · iOS",
      "product": { "id": "client-product", "label": "Client Product" },
      "type": "ios",
      "port": 0,
      "runCommand": "",
      "routes": [{ "path": "/", "label": "Client" }],
      "ios": {
        "project": "ios/AppFamily.xcodeproj",
        "scheme": "Client"
      },
      "testsFile": "oe-tests.json"
    },
    {
      "id": "operator-ios",
      "label": "Operator · iOS",
      "product": { "id": "operator-product", "label": "Operator Product" },
      "type": "ios",
      "port": 0,
      "runCommand": "",
      "routes": [{ "path": "/", "label": "Operator" }],
      "ios": {
        "project": "ios/AppFamily.xcodeproj",
        "scheme": "Operator"
      }
    }
  ]
}
```

Rules:

- Give every target a stable `id`, human label, runtime type, and complete runtime configuration.
- Targets sharing a product ID can be grouped across separately granted repositories.
- Do not place unrestricted absolute sibling-repository paths in target configuration.
- Each referenced repository must still be granted independently through Connector.
- A missing `targets` array remains a normal single-target project.

## Supported `type` values

Use only these values:

- `react`
- `next`
- `astro`
- `shopify`
- `static`
- `ios`
- `android`
- `react-native`
- `expo`
- `unknown`

## Route shape

```json
{
  "path": "/dashboard",
  "label": "Dashboard",
  "states": [
    { "label": "Default", "query": "" },
    { "label": "Admin", "query": "?role=admin" }
  ]
}
```

Rules:

- Every route needs `path` and `label`
- `states` are optional
- Only add `states` when the repo already uses meaningful query-driven variants
- If route inference is weak, emit only `/`

## Shopify data association

Shopify projects may identify the storefront data snapshot by URL:

```json
{
  "integrations": {
    "shopify": {
      "storeUrl": "https://brand.example"
    }
  }
}
```

Keep credentials out of this field. It identifies brand/store data and is not an
authorization mechanism.

## Multi-service stacks

Use `requiredPorts` when the preview depends on more than one local process.

Example:

```json
{
  "name": "autonomous-os",
  "type": "react",
  "port": 9111,
  "requiredPorts": [9111, 8787],
  "runCommand": "bash scripts/start.sh",
  "routes": [
    { "path": "/", "label": "Overview" }
  ]
}
```

Rules:

- Always include the preview/UI port in `requiredPorts`
- Add backend/API ports only when the start command is expected to bring them up too
- Do not invent extra ports if the repo does not clearly declare them

## Safe defaults

When unsure:

- default route to `{ "path": "/", "label": "Home" }`
- do not invent `resolutions`
- do not invent `autoStart`
- do not invent deployment URLs
- prefer a smaller valid config over a broad speculative one

## Screenshot automation

iOS projects with deterministic `oe-swift.json` launch states may opt into background screenshot refresh:

```json
{
  "automation": {
    "afterSourceChange": {
      "action": "captureChangedScreens",
      "enabled": true,
      "debounceMs": 1500
    }
  }
}
```

Rules:

- The Connector observes relevant source files regardless of which editor or agent changed them.
- The action is an internal allowlisted operation; arbitrary commands, hooks, and launch arguments are rejected.
- The project must already be granted to Connector and each captured state must be declared in `oe-swift.json`.
- Use a debounce of at least 750 milliseconds. The Connector clamps values to the safe 0.75–60 second range and runs at most one incremental capture job per project.
- Keep this opt-in because an iOS rebuild can consume substantial local resources.

Agent integrations should call the single `openeditor_screens_capture` MCP tool after a completed edit batch and pass repository-relative `changedFiles`. OpenEditor maps directly declared view files to their states and safely refreshes all states when a shared Swift file, Xcode project, or configuration file changed. Agents then use `openeditor_screens_list` and `openeditor_screens_get`; screenshot bytes remain outside the repository.
