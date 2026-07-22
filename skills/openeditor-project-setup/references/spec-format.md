# OpenEditor Spec Format Reference

Use this file when a user asks to generate an OpenEditor spec, spec graph, project catalog, or richer app/UI definition in addition to `.logic-editor.json`.

## Generator

The repo-level generator is:

```bash
node scripts/generate-openeditor-specs.mjs
```

Default output:

```text
docs/spec-format/generated/
  catalog.spec.json
  index.html
  projects/*.spec.json
```

Useful options:

```bash
node scripts/generate-openeditor-specs.mjs --root . --out docs/spec-format/generated
node scripts/generate-openeditor-specs.mjs --root /path/to/repo --out /tmp/openeditor-specs
node scripts/generate-openeditor-specs.mjs --root . --out /tmp/openeditor-specs --no-html
```

## Project Spec Shape

Each generated project spec uses:

```json
{
  "version": 0,
  "kind": "openeditor-project-spec",
  "project": {
    "name": "my-app",
    "type": "react",
    "root": ".",
    "status": "active"
  },
  "runtime": {
    "kind": "local-command",
    "command": "npm run dev",
    "port": 5173
  },
  "surfaces": [],
  "companions": {},
  "graph": {
    "nodes": [],
    "edges": []
  }
}
```

## Graph Rules

The spec is graph-first:

- `project` nodes anchor the graph.
- `runtime` nodes describe startup.
- `ui-screen` nodes represent route-like surfaces.
- `markup-definition` nodes represent template/theme surfaces.
- `term-definition`, `markup-definition`, `logic-data-definition`, and `logic-snippet-definition` keep vocabulary, markup, data, and snippets separate.
- `acceptance` nodes represent tests or checks.
- `source` nodes represent companion files such as `oe-swift.json`.

Use edges to preserve traceability:

- `derives`
- `uses`
- `implements`
- `depends-on`
- `validates`
- `translates-to`
- `maps-to`
- `conflicts-with`

## Secrets

Never put raw secrets, account IDs, private URLs, or deployment internals in generated specs.

Use generic env references only:

```json
{
  "provider": "deployment-provider",
  "accountIdEnv": "PLATFORM_ACCOUNT_ID",
  "apiTokenEnv": "PLATFORM_API_TOKEN"
}
```

## Existing Docs

The working format docs live in:

- `docs/spec-format/spec-graph-v0.md`
- `docs/spec-format/definition-layers-v0.md`
- `docs/spec-format/project-spec-v0.md`
- `docs/spec-format/ui-spec-v0.md`
