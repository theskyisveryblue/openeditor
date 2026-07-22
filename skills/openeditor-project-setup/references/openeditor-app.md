# OpenEditor App Development

Use this reference when working on OpenEditor itself, not just onboarding an external project. Keep this document general and public-safe.

## App Shape

- root project config: `.logic-editor.json`
- frontend app package
- optional desktop shell
- optional backend service
- optional local filesystem/process bridge
- project registry and startup tooling
- preview/capture engines
- canvas, tests, config, history, style, data, and component views

Find concrete files with local search instead of relying on hardcoded paths. Useful search terms:

- `project-startup`
- `project-config`
- `preview-engine`
- `FrameNode`
- `dom-inspector`
- `component-catalog`
- `DataView`
- `TestsView`
- `agent-sessions`
- `local-command`

## Local Agent Guidance

Keep local agent features in the local desktop runtime unless the user explicitly asks for another deployment shape. Do not expose local agent control protocols from a public backend.

For embedded local-agent UX:

- start the agent bridge as a local child process
- prefer stdio or another local-only transport
- initialize the connection before sending user work
- create or resume a conversation scoped to the selected project path
- pass the selected project path as `cwd`
- stream messages, progress, command output, file diffs, and approval requests into the UI
- answer command/file approvals from the UI
- reuse local auth when available; avoid asking for raw API keys when the local agent already handles auth

Use batch automation instead of an interactive local bridge for CI or one-shot jobs.

## UI And Data Framework Guidance

When adding "look at the UI" features:

- read `references/frameworks.md`
- keep the model centered on surfaces, states, components, tokens, snapshots, and source mappings
- show observed UI separately from declared or inferred UI
- keep framework-specific details behind adapters

When adding "know the APIs/data" features:

- read `references/frameworks.md`
- distinguish used, available, possible, and unknown API surfaces
- connect UI surfaces to API calls, endpoints, entities, schemas, and auth boundaries
- redact secrets and private deployment details

## Verification

Pick the smallest relevant test target:

- Skill/docs changes: `npm run test:skills`
- Frontend unit behavior: `npm run test:frontend`
- Preview/project regressions: `npm run test:frontend:regressions`
- Full repo confidence: `npm test`

When changing desktop-only code, verify the local app still starts with the repo's existing dev command.
