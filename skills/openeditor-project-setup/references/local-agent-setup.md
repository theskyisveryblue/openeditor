# Local Agent Setup

Use this reference when onboarding Codex, Claude, or an experimental OpenCode 2 CLI for an OpenEditor project.

## Detection

Run:

```sh
skills/openeditor-project-setup/scripts/detect-local-agents.sh
```

Treat the result conservatively:

- `installed` means a local command is available.
- `authenticated` means that command reports an active login.
- `method` describes the reported login mechanism when it is available.
- `recommended` is set only when exactly one authenticated agent is available or the user already saved a valid preference.
- `needsChoice` means both agents are authenticated and the user should choose.

Do not infer a paid subscription tier from command availability or authentication. Ask the user when access level materially affects the workflow.

## OpenEditor workflow

Prefer this order:

1. Detect local agents once during onboarding or when the user opens agent settings.
2. Reuse the authenticated agent when only one is available.
3. Reuse the locally saved preference when both are available.
4. Ask one concise agent-choice question only when multiple authenticated providers are available and no preference is saved.
5. Run setup in the local OpenEditor terminal or agent bridge with the selected project as `cwd`.
6. Show progress without keeping heavy project scans or agent processes alive in the background.

Never request raw API keys when the installed agent already manages authentication.

## Copy-and-paste fallback

If the local agent bridge is unavailable, show a short command block the user can paste into their authenticated agent:

```text
Inspect this repository and make it OpenEditor-compatible.
Create or update .logic-editor.json, oe-tests.json, and oe-swift.json when this is a real iOS project.
Preserve existing config, avoid new runtime dependencies, and report inferred fields separately from confirmed fields.
```

The app may run the same instruction in its own terminal after the user confirms the selected project and agent. Keep the fallback visible so onboarding is never blocked by agent integration.
