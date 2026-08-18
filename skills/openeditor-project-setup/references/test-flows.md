# OpenEditor Test Flows

Use `oe-tests.json` for stable product flows and their target-specific executable tests.

```json
{
  "project": "client-app",
  "targetId": "client-ios",
  "bundleId": "com.example.client",
  "flows": [
    {
      "id": "first-time-sign-in",
      "name": "First-time sign-in",
      "description": "Reach verification from the welcome screen.",
      "targetId": "client-ios"
    }
  ],
  "tests": [
    {
      "name": "First-time sign-in checkpoints",
      "flowId": "first-time-sign-in",
      "flow": "First-time sign-in",
      "targetId": "client-ios",
      "type": "ios",
      "steps": [
        { "action": "scenario", "environment": "APP_SCENARIO", "scenario": "welcome" },
        { "action": "screenshot", "name": "Welcome" }
      ]
    }
  ]
}
```

Rules:

- A flow is a specific user goal, not a broad screen category.
- Keep flow IDs stable across captures and target-specific implementations.
- Map every executable test to exactly one `flowId`.
- Use separate flows for branches such as first-time access, session recovery, buyer onboarding, and seller onboarding.
- Use deterministic scenarios only as setup or capture checkpoints. Prefer actual navigation, input, assertions, and captures when reliable automation hooks exist.
- Screenshot capture groups and tests must use the same flow IDs.
- Generated images and run history belong in OpenEditor storage, not the user's source repository.
- Keep the config compact; do not embed image bytes or private user data.
