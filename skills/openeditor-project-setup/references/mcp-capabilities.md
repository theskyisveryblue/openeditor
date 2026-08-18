# MCP Capability Planning

Use this reference when a project exposes MCP configuration, an MCP server could improve the workflow, or the user asks about OpenEditor MCP integrations.

## Capability-first model

Model MCP servers by capability rather than product name:

- source and repository inspection
- browser preview and automation
- design or asset access
- commerce catalog and storefront data
- CMS content and route discovery
- Xcode build, simulator, and accessibility automation
- database or API inspection
- deployment and hosting

Record which capability is needed, which server or native tool can provide it, and the fallback path.

## Detection

The context generator may record repository-local configuration locations such as `.mcp.json`, `.vscode/mcp.json`, or `.cursor/mcp.json`. It must not:

- read or reproduce tokens
- copy command arguments that may include credentials
- inspect unrelated home-directory configuration
- claim a server is connected merely because a config file exists

Classify MCP state as:

- `configured`: a repository-local configuration location exists
- `available`: the current client exposes the capability
- `recommended`: useful for the selected workflow but not required
- `unavailable`: requested capability has no detected provider

Only the active MCP client can confirm actual tools and resources. Prefer MCP resources over repeated filesystem or network scanning when they provide authoritative project context.

## Fallbacks

Every essential operation needs a non-MCP path where practical:

- Xcode MCP automation -> `xcodebuild`, `simctl`, and accessibility helpers
- browser MCP automation -> local preview URL plus built-in capture/inspection
- WordPress content MCP -> REST API, sitemap, or fixture content
- Shopify data MCP -> development-store preview and theme CLI
- filesystem MCP -> workspace filesystem access

An MCP server may improve context quality or interaction speed, but onboarding must state clearly when it is genuinely required.

## Installation and trust

Treat MCP installation as an external capability change:

- identify the exact server and publisher
- review requested permissions and command scope
- avoid embedding secrets in project files
- request explicit user approval
- install only for the client and project that need it
- validate the server exposes the expected tools before relying on it
