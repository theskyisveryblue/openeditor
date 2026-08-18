# Platform Onboarding

Use this reference only for Shopify, WordPress, Apple, or static-generator projects.

## Shopify themes

High-confidence signals:

- `layout/theme.liquid`
- `templates/`
- `sections/`
- `config/settings_schema.json`

Classify JSON templates plus sections as an Online Store 2.0-style theme when the evidence is clear. Candidate surfaces come from `templates/*.json`, `templates/*.liquid`, and known storefront states.

Use the bundled Connector renderer for the current compatibility config:

- `type`: `shopify`
- `port`: `9292`
- `runCommand`: `openeditor-shopify-renderer --theme . --port 9292`

Associate captured or generated storefront data with a public store URL through
structured integration metadata:

```json
{
  "integrations": {
    "shopify": {
      "storeUrl": "https://brand.example"
    }
  }
}
```

The URL is an identifier for the matching local or managed data snapshot; do not
silently scrape or publish the live store during preview. Enumerate every
evidenced `templates/*.json`, `templates/*.liquid`, and customer template as a
labeled route so OpenEditor can place every page template on the canvas.

Do not install Shopify CLI for an OpenEditor preview. Use it only when the user
explicitly requests Shopify's managed development workflow outside the bundled
preview engine. An already-running preview URL remains a valid alternative.

Never publish, push, or modify a live theme as part of onboarding.

## WordPress themes

Detect the project shape before proposing a runtime:

- classic theme: `style.css` with a `Theme Name` header plus PHP templates
- block theme: `theme.json` plus `templates/*.html`
- hybrid theme: both block-theme and classic PHP signals
- child theme: a `Template` header in `style.css`
- full installation: `wp-config.php` or `wp-admin/` and `wp-includes/`
- Bedrock-style installation: `composer.json` plus `web/app/themes/`

Until `wordpress` becomes a supported `.logic-editor.json` type, use `type: "unknown"` for compatibility and retain `platform: "wordpress"` only in generated context.

Prefer runtime choices in this order:

1. Connect to an existing local or remote development URL.
2. Reuse a repo-declared development command or container configuration.
3. Offer a managed `wp-env` environment when its prerequisites already exist or the user approves them.
4. Remain source-only when no safe runtime is available.

Do not require Docker, Node, Composer, WP-CLI, or a database merely to inspect a theme. Treat WooCommerce as an optional WordPress capability profile.

Candidate surfaces should include only evidenced templates and stable routes. The WordPress template hierarchy often makes source mapping probabilistic; report likely owners and confidence instead of claiming an exact mapping.

## Apple projects

Detect:

- `.xcodeproj` and `.xcworkspace`
- Swift packages
- schemes and destinations when Xcode is available
- iOS, iPadOS, macOS, Catalyst, or multiplatform target signals

Keep `oe-swift.json` compatible with the current iOS simulator schema. Record additional Apple platforms and targets in generated runtime context until the application config supports them.

For a future shared Apple runtime, group logical surfaces separately from execution targets:

- iOS Simulator driver
- macOS application driver
- optional Catalyst or visionOS drivers

`xcodebuild` and `simctl` are native execution tools, not package dependencies. XcodeBuildMCP and accessibility helpers are optional enhancements when native fallbacks cover the requested operation.

## Static generators

Recognize at least:

- Hugo: `hugo.toml`, `hugo.yaml`, or `config.toml` with Hugo structure
- Jekyll: `_config.yml` plus `_layouts/` or `_posts/`
- Eleventy: `eleventy.config.*` or `.eleventy.js`
- plain static: `index.html` without a stronger runtime signal

Prefer repo-declared scripts over global tools. Do not install a global generator when a lockfile and project-local command already provide it.

Use `type: "static"` when the current application can serve the result directly. Use `type: "unknown"` when a generator needs a development command not represented by the static runtime.
