# OpenEditor iOS Config

Use this file only for SwiftUI or Xcode-based projects.

## Purpose

`oe-swift.json` tells OpenEditor how to find, build, launch, and capture an iOS project.

`.logic-editor.json` is still the workspace shell, but `oe-swift.json` carries iOS-specific build, launch, and screen-capture data.

Keep `.logic-editor.json`, `oe-swift.json`, and optional `oe-tests.json` at the repository root. OpenEditor generates observed PNGs and their manifest under `~/Library/Application Support/OpenEditor/screen-artifacts/`; agents access them through MCP and should not add generated screenshots or secrets to the repository.

For repositories that also contain macOS or other Apple targets, keep this file compatible with the current iOS schema. Record the broader target matrix in `.openeditor/context/` until a shared Apple runtime config is supported.

## Minimal example

```json
{
  "project": "Pitcher.xcodeproj",
  "scheme": "Pitcher",
  "bundleId": "pafpitcher.Pitcher",
  "views": [
    {
      "name": "ContentView",
      "file": "Pitcher/ContentView.swift",
      "label": "Main",
      "nav": "root",
      "verifyLabels": ["Home"]
    }
  ]
}
```

## Canonical fields

| Field | Type | Notes |
| --- | --- | --- |
| `project` | `string` | Relative path to `.xcodeproj` or `.xcworkspace` |
| `scheme` | `string` | Usually the Xcode project or app name |
| `simulator` | omitted | Do not emit a `simulator` field. Available simulator devices differ per machine, and OpenEditor auto-selects and boots an available simulator. |
| `bundleId` | `string` | Only include when it can be inferred confidently |
| `urlScheme` | `string` | Optional deep-link scheme |
| `launchArgs` | `string[]` | Project-level launch arguments for simulator runs |
| `views` | `array` | Explicit view capture list |
| `bootstrapTapXY` | `{ x, y }` | Optional tap point that reaches a stable demo/root state after cold launch |
| `bootstrapDeepLink` | `string` | Optional deep link that reaches a stable demo/root state before capture |
| `bootstrapWaitMs` | `number` | Optional wait after bootstrap before captures begin |
| `remoteUrl` | `string` | Optional remote build server URL |
| `remoteToken` | `string` | Optional token for the remote build server |

## View object

```json
{
  "name": "ProfileView",
  "file": "Pitcher/ProfileView.swift",
  "label": "Profile",
  "tapLabel": "Profile",
  "verifyLabels": ["Profile"]
}
```

Supported view-level fields include:

- `name`
- `file`
- `label`
- `device`
- `deepLink`
- `tapLabel`
- `tapId`
- `tapXY`
- `nav`
- `tabIndex`
- `parent`
- `requiresLogout`
- `launchArgs`
- `verifyLabels`

Only add advanced fields when the repo clearly supports them.

## Safe generation rules

- infer `scheme` from the `.xcodeproj` or `.xcworkspace` name when possible
- if multiple projects, workspaces, or shared app schemes exist, enumerate them and inspect product/bundle evidence before choosing; never use filesystem order as the selection rule
- use compound `targets` for independently runnable Apple apps and keep the evidence-backed active app in the backward-compatible top-level fields
- infer `project` when the Xcode project is nested
- if a real `.xcodeproj` or `.xcworkspace` exists, include `project`; omitting it makes the result invalid for simulator preview
- never emit a `simulator` field or a macOS destination; OpenEditor auto-selects an available simulator
- include obvious `*View.swift` files in `views`
- prefer fewer accurate views over a long speculative list
- use project-relative file paths, not absolute local paths
- do not fabricate bundle IDs, deep links, launch args, bootstrap actions, or remote credentials
- if the repo only contains `Package.swift` and Swift source files, classify the result as source-only until a host app / installable Xcode target is provided
- for source-only Swift packages, `scheme` and `views` may still be inferred, but simulator capture is not preview-ready until `project` points at a real `.xcodeproj` or `.xcworkspace`
- treat XcodeBuildMCP and accessibility helpers as optional enhancements when native tools provide a sufficient fallback
