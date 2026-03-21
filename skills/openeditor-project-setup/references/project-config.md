# OpenEditor Project Config

Use this file for the canonical `.logic-editor.json` shape.

## Minimal shape

```json
{
  "name": "my-project",
  "type": "react",
  "port": 5173,
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
| `runCommand` | `string` | usually | Empty string is valid for mobile or iOS projects |
| `routes` | `array` | yes | At least one route |
| `platform` | `string` | no | Useful for mobile projects |
| `resolutions` | `number[]` | no | Widths for generated preview frames |
| `autoStart` | `boolean` | no | Whether OpenEditor should auto-start the local preview |
| `mobile` | `object` | no | Mobile metadata |
| `ios` | `object` | no | iOS metadata when embedded inside `.logic-editor.json` |
| `integrations` | `object` | no | Optional integration metadata |

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

## Safe defaults

When unsure:

- default route to `{ "path": "/", "label": "Home" }`
- do not invent `resolutions`
- do not invent `autoStart`
- do not invent deployment URLs
- prefer a smaller valid config over a broad speculative one
