# OpenEditor Skills

Install the project setup skill:

```bash
npx skills add theskyisveryblue/openeditor --skill openeditor-project-setup
```

## openeditor-project-setup

Inspects an existing repo and creates or updates the OpenEditor files needed to preview, test, inspect, and document an app.

Outputs:
- `.logic-editor.json`
- `oe-tests.json` when stable preview/test flows are discoverable
- `oe-swift.json` for iOS or SwiftUI repos
- `openeditor.spec.json` or generated spec output when requested

The skill can also help with:

- framework, port, route, and local run-command detection
- iOS/SwiftUI preview readiness versus source-only classification
- UI inventory for screens, components, states, tokens, snapshots, and source mappings
- data/API inventory for endpoints, entities, schemas, auth boundaries, and observed usage
- public-safe source-tagging guidance using generic `data-ui-*` attributes

Use:

```text
Use the openeditor-project-setup skill on this repo and generate .logic-editor.json.
For iOS or SwiftUI repos, generate oe-swift.json too.
If the app can be instrumented, suggest data-ui-* tags for component and screen extraction.
```

## UI Source Tags

When source markup can be edited, the skill recommends sparse generic tags such as:

- `data-ui-component`
- `data-ui-component-id`
- `data-ui-family`
- `data-ui-kind`
- `data-ui-part`
- `data-ui-state`
- `data-ui-variant`
- `data-ui-platform`
- `data-ui-surface`
- `data-ui-source`

These tags are intended to help OpenEditor map rendered UI back to reusable components, surfaces, states, variants, and source files across web, native, template, and static projects.
