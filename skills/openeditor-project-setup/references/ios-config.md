# OpenEditor iOS Config

Use this file only for SwiftUI or Xcode-based projects.

## Purpose

`oe-swift.json` tells OpenEditor how to find, boot, and capture an iOS project.

`.logic-editor.json` is still used as the workspace shell, but `oe-swift.json` carries the simulator and view data.

## Minimal example

```json
{
  "name": "Pitcher",
  "scheme": "Pitcher",
  "simulator": "iPhone 16 Pro",
  "bundleId": "pafpitcher.Pitcher",
  "views": [
    {
      "name": "ContentView",
      "file": "ContentView.swift",
      "label": "Main",
      "nav": "root"
    }
  ]
}
```

## Important fields

| Field | Type | Notes |
| --- | --- | --- |
| `project` | `string` | Relative path to `.xcodeproj` or `.xcworkspace` |
| `scheme` | `string` | Usually the Xcode project or app name |
| `simulator` | `string` | Default to `iPhone 16 Pro` unless the repo strongly suggests another target |
| `bundleId` | `string` | Only include when it can be inferred confidently |
| `urlScheme` | `string` | Optional deep-link scheme |
| `views` | `array` | Explicit view capture list |

## View object

```json
{
  "name": "ProfileView",
  "file": "Pitcher/ProfileView.swift",
  "label": "Profile"
}
```

Only add advanced fields like `deepLink`, `tapLabel`, `tapId`, `tapXY`, `verifyLabels`, or `launchArgs` when the repo clearly supports them.

## Safe generation rules

- infer `scheme` from the `.xcodeproj` or `.xcworkspace` name when possible
- infer `project` when the Xcode project is nested
- include obvious `*View.swift` files in `views`
- prefer fewer accurate views over a long speculative list
- do not fabricate bundle IDs or deep links
