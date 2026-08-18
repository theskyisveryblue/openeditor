# OpenEditor UI And Data Frameworks

Use this reference when designing features that let a user inspect an app visually or understand its data/API surface. Keep the model general and public-safe.

## UI Inventory Framework

Represent UI as inspectable surfaces rather than as one-off screenshots.

Core objects:

- `ui-surface`: a route, screen, template, native view, modal, or major state
- `ui-state`: query state, auth state, fixture state, device size, locale, theme, or interaction state
- `ui-component`: repeated or named UI unit discovered from source, DOM, native view metadata, or component catalogs
- `ui-token`: color, typography, spacing, radius, shadow, motion, or asset token
- `ui-snapshot`: screenshot, DOM summary, accessibility tree, native hierarchy, or HTML sample
- `source-map`: links UI objects back to files, selectors, symbols, routes, or tests

Evidence levels:

- `observed`: captured from a running preview, screenshot, DOM, accessibility tree, or network trace
- `declared`: found in config, route files, component registries, schema files, or tests
- `inferred`: derived from framework conventions or stable naming patterns
- `possible`: exposed by source or schema but not yet observed in a running state

Rules:

- keep screenshots and DOM summaries separate from source-derived component lists
- preserve source mappings so a user can move from a visual object to likely files
- record viewport and device context with every visual snapshot
- keep labels human-readable, but avoid inventing precise behavior without evidence
- support web, native, theme/template, and static projects with the same vocabulary

## Data/API Inventory Framework

Represent data/API usage as both what the app uses today and what the project appears able to use.

Core objects:

- `api-call`: an observed or source-declared request from app code
- `api-endpoint`: an available route, RPC, local command, SDK method, or backend handler
- `data-entity`: durable concept such as user, project, workspace, product, file, session, or event
- `data-schema`: JSON schema, validation schema, TypeScript type, database table, GraphQL type, or OpenAPI shape
- `data-flow`: relationship from UI surface to API call to endpoint to entity/schema
- `auth-boundary`: required auth mode, token source, permission, or local-only constraint
- `integration`: external or local system used by the app

Classify API surfaces:

- `used`: called by runtime code or observed in network traces
- `available`: implemented by backend/server/source but not observed from the current UI path
- `possible`: implied by SDK clients, OpenAPI documents, generated types, route conventions, or installed integrations
- `unknown`: referenced indirectly without enough evidence to classify

Rules:

- never store raw secrets, tokens, account IDs, private URLs, or customer data in generated specs
- replace sensitive values with env references such as `PLATFORM_API_TOKEN` or `SERVICE_BASE_URL`
- separate public API shape from private operational details
- keep provider names generic unless the provider is required to understand a public integration
- link every API/data object to source evidence when possible
- prefer structured parsers and existing schemas over regular-expression guesses

## Suggested Graph Edges

Use these edge labels consistently:

- `renders`: surface renders component
- `captures`: snapshot captures surface or state
- `maps-to`: UI object maps to source, schema, or route
- `calls`: component or surface calls API
- `serves`: endpoint serves entity or schema
- `requires`: API or data flow requires auth boundary
- `validates`: test validates surface, endpoint, or data flow
- `depends-on`: object depends on runtime, service, or integration

## Output Shape

When generating a framework artifact, prefer this structure:

```json
{
  "version": 0,
  "kind": "openeditor-inspection-framework",
  "project": { "name": "example", "type": "react" },
  "ui": {
    "surfaces": [],
    "states": [],
    "components": [],
    "tokens": [],
    "snapshots": []
  },
  "data": {
    "apiCalls": [],
    "endpoints": [],
    "entities": [],
    "schemas": [],
    "flows": [],
    "authBoundaries": [],
    "integrations": []
  },
  "graph": {
    "nodes": [],
    "edges": []
  }
}
```
