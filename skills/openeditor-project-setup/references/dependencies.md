# Capability and Dependency Planning

Use this reference when tools are missing or the user asks OpenEditor to prepare a runtime.

## Discovery never installs

Separate the workflow into:

1. detect project evidence
2. detect existing capabilities
3. select a preview strategy
4. produce an install plan
5. obtain user approval
6. install only approved missing requirements
7. regenerate context and validate

Never combine discovery and installation in one script.

## Rank by capability

Every dependency decision must include:

- capability needed
- why the selected workflow needs it
- whether a native or existing fallback exists
- status: `present`, `missing`, `unknown`, or `not-applicable`
- importance: `required`, `recommended`, or `optional`
- scope: project-local, user-local, system, or external service
- provider selected from evidence already present in the repo

Do not install an implementation merely because it is popular. First establish that the requested capability is unavailable.

## Selection order

Prefer:

1. an existing repo command
2. an existing lockfile and project-local package
3. a native platform tool
4. an already-configured MCP capability
5. an external development URL
6. a new project-local dependency
7. a user-local CLI
8. a system-wide package or container runtime

System-wide tools and container runtimes require especially clear justification.

## Platform examples

- Shopify source inspection needs no Shopify CLI; managed preview does.
- WordPress theme inspection needs no PHP, database, Docker, or Node; a managed WordPress environment may.
- Apple source inventory needs no Xcode invocation; local building and simulator preview need Xcode.
- Hugo should use a repo script or existing Hugo binary before proposing an install.
- An MCP server is optional when a local/native fallback supplies the same capability.

## Install execution

Do not emit or run an installation command until the package manager and scope are confirmed. Keep installation commands out of generated context when they could become stale or platform-specific; record the capability and provider instead.

After approval, install the smallest set that makes the selected workflow usable. Re-run context generation and remove obsolete recommendations.
