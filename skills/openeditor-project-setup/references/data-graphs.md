# OpenEditor Flow Documents

Use this reference to create project-owned documents for the OpenEditor **Flows** pane.

## Storage and discovery

Write direct graph documents to:

```text
.uidesign/flows/<flow-name>.data-graph.json
```

OpenEditor discovers any valid direct `*.data-graph.json` file in the project. It can also discover graph documents embedded in a JSON file's `relatedArtifactDocuments` array. Prefer direct files because they are independently editable, reviewable, and versioned.

Flow documents are independent from App Preview. Do not derive or update them from the selected route, running process, canvas viewport, or pane state.

## What to generate

Generate a graph only when repository evidence supports meaningful entities and relationships. Useful evidence includes:

- monorepo packages and declared dependencies
- service clients, route handlers, API schemas, and database models
- infrastructure and deployment declarations
- authentication policies and authorization boundaries
- background jobs, queues, webhooks, and event consumers
- architecture or operational documentation that agrees with source

Common documents include `architecture`, `data-flow`, `delivery`, `users-and-access`, and `security`. These are examples, not required categories. The project owns the document names, group names, nodes, focus presets, and scope.

Do not turn a list of App Preview routes into architecture. Routes can be supporting evidence for product surfaces, but they cannot establish system relationships by themselves.

## Evidence and updates

- Preserve existing user-authored nodes, layout, labels, and extensions unless source evidence proves they are stale.
- Prefer a small accurate graph over a comprehensive speculative graph.
- Add source evidence to `node.extensions.fileKeys` or `edge.extensions.fileKeys` when practical.
- Mark inferred relationships with `extensions.evidence: "inferred"`; use `"declared"` for explicit configuration or documentation.
- Never include secrets, credentials, private payloads, or raw environment values.

## Minimal valid document

```json
{
  "schema": "uidesign.data-graph/v1",
  "id": "project:architecture",
  "title": "Architecture",
  "groupsById": {
    "clients": { "id": "clients", "label": "Clients", "tone": "violet", "order": 0 },
    "services": { "id": "services", "label": "Services", "tone": "blue", "order": 1 }
  },
  "nodesById": {
    "web-app": {
      "id": "web-app",
      "kind": "output",
      "label": "Web app",
      "groupId": "clients",
      "ports": [{ "id": "request", "label": "API request", "direction": "output", "dataType": "api.request" }],
      "extensions": { "fileKeys": ["src/app.tsx"], "evidence": "declared" }
    },
    "api": {
      "id": "api",
      "kind": "transform",
      "label": "API",
      "groupId": "services",
      "ports": [{ "id": "request", "label": "API request", "direction": "input", "dataType": "api.request" }],
      "extensions": { "fileKeys": ["src/api.ts"], "evidence": "declared" }
    }
  },
  "edgesById": {
    "web-to-api": {
      "id": "web-to-api",
      "kind": "data",
      "source": { "nodeId": "web-app", "portId": "request" },
      "target": { "nodeId": "api", "portId": "request" },
      "label": "requests",
      "extensions": { "fileKeys": ["src/client.ts"], "evidence": "declared" }
    }
  },
  "layout": {
    "groupsById": {
      "clients": { "position": { "x": 0, "y": 0 }, "width": 360, "height": 360 },
      "services": { "position": { "x": 420, "y": 0 }, "width": 360, "height": 360 }
    },
    "nodesById": {
      "web-app": { "position": { "x": 30, "y": 80 }, "width": 300 },
      "api": { "position": { "x": 450, "y": 80 }, "width": 300 }
    }
  },
  "extensions": {
    "focusPresets": [
      { "id": "main", "label": "Main flow", "groupIds": ["clients", "services"] },
      { "id": "all", "label": "All", "groupIds": ["clients", "services"] }
    ]
  }
}
```

## Validation

From the installed skill directory:

```bash
node scripts/validate-data-graph.mjs /path/to/project/.uidesign/flows/architecture.data-graph.json
```

Validation checks identifiers, layouts, group membership, typed ports, edge direction, and compatible data types. Fix validation failures before reporting generation complete.

## Regeneration command

Regeneration defaults to manual and dry-run:

```bash
openeditor flows check --root .
openeditor flows refresh --root .
```

The second command prints the exact agent instructions without changing files. To explicitly launch the project-scoped Codex update:

```bash
openeditor flows refresh --root . --apply
```

The applied command uses an ephemeral Codex session with the `workspace-write` sandbox. It requires candidate generation, validation, and diff inspection before replacing flow documents. It does not grant unrestricted filesystem access and does not commit changes.
