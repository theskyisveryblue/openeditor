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
| `routes` | `array` | usually | At least one route, unless `pages` provides grouped routes |
| `pages` | `array` | no | Optional route groups for projects with many pages or states |
| `platform` | `string` | no | Useful for mobile projects |
| `resolutions` | `number[]` | no | Widths for generated preview frames |
| `canvas` | `object` | no | Canvas-level workspace settings, for example generated artboard layout |
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

## Canvas shape

```json
{
  "canvas": {
    "artboardsPerRow": 2
  }
}
```

Rules:

- `artboardsPerRow` controls generated preview groups on the canvas
- use `2` by default for release workspaces
- valid values are `1`, `2`, or `3`
- If route inference is weak, emit only `/`

## Page grouping

Use `pages` when a project has enough routes or route states that the top-level config becomes hard to scan. OpenEditor flattens page routes internally for previews, so `routes` can be omitted when `pages` is present.

```json
{
  "name": "contacts",
  "type": "astro",
  "port": 8741,
  "runCommand": "./start.sh",
  "pages": [
    {
      "id": "directory",
      "label": "Directory",
      "routes": [
        { "path": "/contacts", "label": "Contacts" },
        { "path": "/companies", "label": "Companies" }
      ]
    },
    {
      "id": "analysis",
      "label": "Analysis",
      "routes": [
        {
          "path": "/network",
          "label": "Network Graph",
          "states": [
            { "label": "Default", "query": "" },
            { "label": "Recent", "query": "?range=recent" }
          ]
        }
      ]
    }
  ]
}
```

Rules:

- Keep page groups user-facing and small, such as `Directory`, `Workflow`, `Analysis`, or `Settings`
- Put route `states` inside the route they modify
- Do not duplicate the same route in both top-level `routes` and `pages`
- Use top-level `routes` for small projects; use `pages` when grouping improves readability

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
