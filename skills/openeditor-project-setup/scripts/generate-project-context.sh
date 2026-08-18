#!/bin/sh
set -eu

usage() {
  printf '%s\n' "Usage: generate-project-context.sh [--repo PATH] [--output PATH]"
}

repo=.
output=

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      repo=$2
      shift 2
      ;;
    --output)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      output=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
done

[ -d "$repo" ] || { printf 'Repository not found: %s\n' "$repo" >&2; exit 1; }
repo=$(CDPATH= cd -- "$repo" && pwd)
[ -n "$output" ] || output="$repo/.openeditor/context"

case "$output" in
  /*) ;;
  *) output="$repo/$output" ;;
esac

mkdir -p "$output"

signals="$output/signals.tsv"
tools="$output/tools.tsv"
dependencies="$output/dependencies.tsv"
mcp="$output/mcp.tsv"
platforms="$output/platforms.tsv"
surfaces="$output/surfaces.txt"
files="$output/files.txt"
graphs="$output/graphs.tsv"
graph_focus="$output/graph-focus.tsv"

: >"$signals"
: >"$tools"
: >"$dependencies"
: >"$mcp"
: >"$platforms"
: >"$surfaces"
: >"$files"
: >"$graphs"
: >"$graph_focus"

rel() {
  case "$1" in
    "$repo") printf '.\n' ;;
    "$repo"/*) printf '%s\n' "${1#"$repo"/}" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

signal() {
  printf '%s\t%s\t%s\n' "$1" "$2" "$3" >>"$signals"
}

tool() {
  tool_name=$1
  capability=$2
  importance=$3
  if command -v "$tool_name" >/dev/null 2>&1; then
    status=present
  else
    status=missing
  fi
  printf '%s\t%s\t%s\t%s\n' "$tool_name" "$status" "$capability" "$importance" >>"$tools"
}

dependency() {
  printf '%s\t%s\t%s\t%s\t%s\n' "$1" "$2" "$3" "$4" "$5" >>"$dependencies"
}

first_match() {
  find "$repo" \
    \( -name .git -o -name node_modules -o -name dist -o -name build -o -name .next -o -name .openeditor -o -name .oe-build -o -name DerivedData -o -name vendor -o -name fixtures -o -name test -o -name tests -o -name __tests__ \) -prune -o \
    "$@" -print 2>/dev/null | head -n 1
}

project_name=$(basename "$repo")
platform=unknown
variant=unknown
compatibility_type=unknown
confidence=low
readiness=source-only
package_manager=none
configured_type=

if [ -f "$repo/.logic-editor.json" ]; then
  configured_type=$(
    sed -n 's/.*"type"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$repo/.logic-editor.json" |
      head -n 1
  )
fi

if [ -f "$repo/bun.lock" ] || [ -f "$repo/bun.lockb" ]; then
  package_manager=bun
elif [ -f "$repo/pnpm-lock.yaml" ]; then
  package_manager=pnpm
elif [ -f "$repo/yarn.lock" ]; then
  package_manager=yarn
elif [ -f "$repo/package-lock.json" ]; then
  package_manager=npm
fi

shopify_layout=
[ -f "$repo/layout/theme.liquid" ] && shopify_layout="$repo/layout/theme.liquid"
wordpress_style=$(
  find "$repo" \
    \( -name .git -o -name node_modules -o -name dist -o -name build -o -name .openeditor -o -name .oe-build -o -name vendor -o -name fixtures -o -name test -o -name tests -o -name __tests__ \) -prune -o \
    -type f -name style.css -print 2>/dev/null |
    while IFS= read -r path; do
      if grep -Eiq '^[[:space:]]*(/\*)?[[:space:]]*(\*)?[[:space:]]*Theme Name[[:space:]]*:' "$path"; then
        printf '%s\n' "$path"
        break
      fi
    done
)
xcode_project=$(first_match -type d \( -name '*.xcodeproj' -o -name '*.xcworkspace' \))
xcode_project_count=$(
  find "$repo" \
    \( -name .git -o -name node_modules -o -name dist -o -name build -o -name DerivedData -o -name .openeditor -o -name .oe-build \) -prune -o \
    -type d \( -name '*.xcodeproj' -o -name '*.xcworkspace' \) -print 2>/dev/null |
    wc -l |
    tr -d '[:space:]'
)

if [ -n "$shopify_layout" ] && [ -d "$repo/templates" ]; then
  platform=shopify
  compatibility_type=shopify
  confidence=high
  readiness=needs-runtime
  variant=liquid-theme
  if first_match -type f -path '*/templates/*.json' | grep -q .; then
    variant=online-store-2
  fi
  signal platform layout/theme.liquid "Shopify theme layout"
  signal platform templates "Shopify template directory"
elif [ -f "$repo/wp-config.php" ] || { [ -d "$repo/wp-admin" ] && [ -d "$repo/wp-includes" ]; }; then
  platform=wordpress
  compatibility_type=unknown
  confidence=high
  readiness=needs-runtime
  variant=wordpress-installation
  signal platform . "Complete WordPress installation"
elif [ -f "$repo/composer.json" ] && [ -d "$repo/web/app/themes" ]; then
  platform=wordpress
  compatibility_type=unknown
  confidence=high
  readiness=needs-runtime
  variant=bedrock-installation
  signal platform web/app/themes "Bedrock-style WordPress installation"
elif [ -n "$wordpress_style" ]; then
  platform=wordpress
  compatibility_type=unknown
  confidence=high
  readiness=needs-external-runtime
  variant=classic-theme
  wordpress_root=$(dirname "$wordpress_style")
  if [ -f "$wordpress_root/theme.json" ] && [ -d "$wordpress_root/templates" ]; then
    variant=block-theme
    if find "$wordpress_root" -type f -name '*.php' -print 2>/dev/null | head -n 1 | grep -q .; then
      variant=hybrid-theme
    fi
  fi
  if grep -Eiq '^[[:space:]]*(\*)?[[:space:]]*Template[[:space:]]*:' "$wordpress_style"; then
    case "$variant" in
      block-theme) variant=block-child-theme ;;
      hybrid-theme) variant=hybrid-child-theme ;;
      *) variant=classic-child-theme ;;
    esac
  fi
  signal platform "$(rel "$wordpress_style")" "WordPress theme header"
  [ ! -f "$wordpress_root/theme.json" ] || signal variant "$(rel "$wordpress_root/theme.json")" "Block theme configuration"
elif [ -n "$xcode_project" ] || [ -f "$repo/Package.swift" ]; then
  platform=apple
  compatibility_type=ios
  confidence=high
  variant=swift-package
  readiness=source-only
  if [ -n "$xcode_project" ]; then
    variant=apple-app
    readiness=needs-runtime
    signal platform "$(rel "$xcode_project")" "Xcode project or workspace"
    if [ "${xcode_project_count:-0}" -gt 1 ]; then
      find "$repo" \
        \( -name .git -o -name node_modules -o -name dist -o -name build -o -name DerivedData -o -name .openeditor -o -name .oe-build \) -prune -o \
        -type d \( -name '*.xcodeproj' -o -name '*.xcworkspace' \) -print 2>/dev/null |
        sort |
        while IFS= read -r apple_project; do
          signal target "$(rel "$apple_project")" "Candidate Xcode project or workspace; inspect schemes before choosing the active app"
        done
    fi
    apple_has_mac=false
    apple_has_ios=false
    if find "$repo" \
      \( -name .git -o -name .build -o -name build -o -name DerivedData \) -prune -o \
      -type f \( -name '*.swift' -o -name project.pbxproj \) \
      -exec grep -Eil 'os\(macOS\)|AppKit|SDKROOT[[:space:]]*=[[:space:]]*macosx|MACOSX_DEPLOYMENT_TARGET' {} + 2>/dev/null |
      head -n 1 | grep -q .; then
      apple_has_mac=true
    fi
    if find "$repo" \
      \( -name .git -o -name .build -o -name build -o -name DerivedData \) -prune -o \
      -type f \( -name '*.swift' -o -name project.pbxproj \) \
      -exec grep -Eil 'os\(iOS\)|UIKit|SDKROOT[[:space:]]*=[[:space:]]*iphoneos|IPHONEOS_DEPLOYMENT_TARGET' {} + 2>/dev/null |
      head -n 1 | grep -q .; then
      apple_has_ios=true
    fi
    if [ "$apple_has_mac" = true ] && [ "$apple_has_ios" = true ]; then
      variant=multiplatform
    elif [ "$apple_has_mac" = true ]; then
      variant=macos-app
    elif [ "$apple_has_ios" = true ]; then
      variant=ios-app
    fi
  else
    signal platform Package.swift "Swift package without an installable Xcode project"
  fi
elif [ -f "$repo/hugo.toml" ] || [ -f "$repo/hugo.yaml" ] || { [ -f "$repo/config.toml" ] && [ -d "$repo/layouts" ]; }; then
  platform=static
  variant=hugo
  compatibility_type=unknown
  confidence=high
  readiness=needs-runtime
  signal platform layouts "Hugo project structure"
elif [ -f "$repo/_config.yml" ] && { [ -d "$repo/_layouts" ] || [ -d "$repo/_posts" ]; }; then
  platform=static
  variant=jekyll
  compatibility_type=unknown
  confidence=high
  readiness=needs-runtime
  signal platform _config.yml "Jekyll configuration"
elif [ -f "$repo/.eleventy.js" ] || [ -f "$repo/eleventy.config.js" ] || [ -f "$repo/eleventy.config.mjs" ] || [ -f "$repo/eleventy.config.cjs" ]; then
  platform=static
  variant=eleventy
  compatibility_type=unknown
  confidence=high
  readiness=needs-runtime
  signal platform eleventy.config "Eleventy configuration"
elif [ -f "$repo/package.json" ]; then
  platform=web
  readiness=needs-runtime
  confidence=medium
  if grep -q '"next"' "$repo/package.json"; then
    variant=next
    compatibility_type=next
  elif grep -q '"astro"' "$repo/package.json"; then
    variant=astro
    compatibility_type=astro
  elif grep -q '"expo"' "$repo/package.json"; then
    platform=mobile
    variant=expo
    compatibility_type=expo
  elif grep -q '"react-native"' "$repo/package.json"; then
    platform=mobile
    variant=react-native
    compatibility_type=react-native
  elif grep -q '"react"' "$repo/package.json"; then
    variant=react
    compatibility_type=react
  else
    variant=node-web
  fi
  signal platform package.json "Package manifest"
elif [ -f "$repo/index.html" ]; then
  platform=static
  variant=plain-html
  compatibility_type=static
  confidence=high
  readiness=preview-ready
  signal platform index.html "Static entry point"
fi

case "$configured_type" in
  react|next|astro)
    platform=web
    variant=$configured_type
    compatibility_type=$configured_type
    confidence=high
    readiness=needs-runtime
    signal configured .logic-editor.json "Existing OpenEditor project type"
    ;;
  shopify)
    platform=shopify
    compatibility_type=shopify
    confidence=high
    readiness=needs-runtime
    [ "$variant" != unknown ] || variant=liquid-theme
    signal configured .logic-editor.json "Existing OpenEditor project type"
    ;;
  static)
    platform=static
    compatibility_type=static
    confidence=high
    [ "$variant" != unknown ] || variant=plain-html
    signal configured .logic-editor.json "Existing OpenEditor project type"
    ;;
  ios)
    platform=apple
    compatibility_type=ios
    confidence=high
    readiness=needs-runtime
    [ "$variant" != unknown ] || variant=ios-app
    signal configured .logic-editor.json "Existing OpenEditor project type"
    ;;
  android|react-native|expo)
    platform=mobile
    variant=$configured_type
    compatibility_type=$configured_type
    confidence=high
    readiness=needs-runtime
    signal configured .logic-editor.json "Existing OpenEditor project type"
    ;;
  unknown|"")
    ;;
esac

printf 'primary\t%s\t%s\t%s\n' "$platform" "$variant" "Selected project runtime" >>"$platforms"

if [ "$platform" != apple ] && [ -n "$xcode_project" ]; then
  printf 'secondary\tapple\tunknown\t%s\n' "$(rel "$xcode_project")" >>"$platforms"
fi
if [ "$platform" != wordpress ] && { [ -n "$wordpress_style" ] || [ -f "$repo/wp-config.php" ] || [ -d "$repo/web/app/themes" ]; }; then
  printf 'secondary\twordpress\tunknown\tWordPress source detected in workspace\n' >>"$platforms"
fi
if [ "$platform" != shopify ] && [ -n "$shopify_layout" ]; then
  printf 'secondary\tshopify\tliquid-theme\tlayout/theme.liquid\n' >>"$platforms"
fi

platform_count=$(wc -l <"$platforms" | tr -d ' ')
runtime_layout=single-runtime
[ "$platform_count" -le 1 ] || runtime_layout=multi-runtime

find "$repo" \
  \( -name .git -o -name node_modules -o -name dist -o -name build -o -name .next -o -name .openeditor -o -name DerivedData -o -name vendor \) -prune -o \
  -type f \( \
    -name package.json -o -name composer.json -o -name Gemfile -o -name Package.swift -o \
    -name '*.xcodeproj' -o -name project.pbxproj -o -name '*.liquid' -o \
    -name theme.json -o -name style.css -o -name '*.php' -o -name '*.html' -o \
    -name '*.astro' -o -name '*.tsx' -o -name '*.swift' -o -name '_config.yml' -o \
    -name 'hugo.toml' -o -name 'hugo.yaml' -o -name 'eleventy.config.*' \
  \) -print 2>/dev/null | while IFS= read -r path; do rel "$path"; done | head -n 500 >"$files"

# Graph discovery intentionally uses only standard shell/file tools. The app
# performs strict JSON and reference validation when it opens these artifacts.
find "$repo" \
  \( -name .git -o -name node_modules -o -name dist -o -name build -o -name .next -o -name .openeditor -o -name DerivedData -o -name vendor \) -prune -o \
  -type f -name '*.json' -print 2>/dev/null |
  while IFS= read -r path; do
    if ! grep -Eq '"schema"[[:space:]]*:[[:space:]]*"uidesign\.data-graph/v1"' "$path"; then
      continue
    fi

    relative_path=$(rel "$path")
    graph_detected=false
    case "$path" in
      *.data-graph.json)
        printf '%s\t%s\t%s\n' "$relative_path" direct "$(basename "$path")" >>"$graphs"
        graph_detected=true
        ;;
      *)
        artifact_keys=$(
          grep -Eo '"key"[[:space:]]*:[[:space:]]*"[^"]+\.data-graph\.json"' "$path" 2>/dev/null |
            sed 's/^[^"]*"key"[[:space:]]*:[[:space:]]*"//; s/"$//' |
            sort -u
        )
        if [ -n "$artifact_keys" ]; then
          printf '%s\n' "$artifact_keys" |
            while IFS= read -r artifact_key; do
              printf '%s\t%s\t%s\n' "$relative_path" embedded "$artifact_key" >>"$graphs"
            done
          graph_detected=true
        fi
        ;;
    esac

    [ "$graph_detected" = true ] || continue
    if grep -Eq '"focusPresets"[[:space:]]*:' "$path"; then
      printf '%s\t%s\t%s\n' "$relative_path" explicit "Graph declares semantic focus presets" >>"$graph_focus"
    else
      printf '%s\t%s\t%s\n' "$relative_path" legacy-order-fallback "Main <=4, delivery =5, notes >=6, plus all" >>"$graph_focus"
    fi
  done

graph_artifact_count=$(wc -l <"$graphs" | tr -d ' ')

case "$platform:$variant" in
  shopify:*)
    find "$repo/templates" -type f \( -name '*.json' -o -name '*.liquid' \) -print 2>/dev/null |
      while IFS= read -r path; do rel "$path"; done | sort | head -n 200 >"$surfaces"
    tool shopify managed-shopify-preview recommended
    dependency managed-preview recommended "$(command -v shopify >/dev/null 2>&1 && printf present || printf missing)" user-local "Shopify CLI; unnecessary for source-only or external-URL workflows"
    ;;
  wordpress:*)
    wordpress_root=$repo
    [ -z "$wordpress_style" ] || wordpress_root=$(dirname "$wordpress_style")
    find "$wordpress_root" \
      \( -name vendor -o -name node_modules -o -name .git -o -name .openeditor \) -prune -o \
      -type f \( -name '*.php' -o -path '*/templates/*.html' -o -path '*/parts/*.html' -o -path '*/patterns/*.php' \) -print 2>/dev/null |
      while IFS= read -r path; do rel "$path"; done | sort | head -n 200 >"$surfaces"
    tool wp content-and-route-discovery optional
    tool docker managed-wordpress-runtime optional
    tool php local-wordpress-runtime optional
    dependency theme-inspection required present none "Uses repository files only"
    dependency wordpress-runtime recommended unknown external "Prefer an existing development URL before installing a local stack"
    dependency managed-wp-env optional unknown project-local "Consider only after Node and a container provider are approved"
    ;;
  apple:*)
    find "$repo" \
      \( -name .git -o -name .build -o -name build -o -name DerivedData \) -prune -o \
      -type f -name '*View.swift' -print 2>/dev/null |
      while IFS= read -r path; do rel "$path"; done | sort | head -n 200 >"$surfaces"
    tool xcodebuild apple-build required
    tool xcrun simulator-and-sdk-access required
    tool xcodebuildmcp enhanced-apple-automation optional
    tool axe accessibility-automation optional
    dependency source-inventory required present none "Uses repository files only"
    dependency local-apple-preview required "$(command -v xcodebuild >/dev/null 2>&1 && printf present || printf missing)" system "Xcode command-line tools"
    dependency enhanced-automation optional "$(command -v xcodebuildmcp >/dev/null 2>&1 && printf present || printf missing)" user-local "Use only when native fallbacks do not cover the requested workflow"
    ;;
  static:hugo)
    tool hugo static-generator recommended
    dependency preview-runtime recommended "$(command -v hugo >/dev/null 2>&1 && printf present || printf missing)" project-or-user "Prefer a repo-declared command before a global install"
    ;;
  static:jekyll)
    tool bundle ruby-package-runner recommended
    tool jekyll static-generator recommended
    dependency preview-runtime recommended unknown project-local "Prefer the checked-in Gemfile and bundle exec"
    ;;
  static:eleventy)
    tool node javascript-runtime recommended
    dependency preview-runtime recommended "$(command -v node >/dev/null 2>&1 && printf present || printf missing)" project-local "Prefer the lockfile and package script"
    ;;
  web:*|mobile:*)
    if [ "$package_manager" != none ]; then
      tool "$package_manager" project-package-manager recommended
    else
      printf 'package-manager\tunknown\tproject-package-manager\trecommended\n' >>"$tools"
    fi
    dependency preview-runtime recommended unknown project-local "Use the repository lockfile and declared scripts"
    ;;
  *)
    dependency source-inspection required present none "No additional dependency required"
    ;;
esac

for config in .mcp.json mcp.json .vscode/mcp.json .cursor/mcp.json .codex/config.toml; do
  if [ -f "$repo/$config" ]; then
    printf 'configured\t%s\trepository-config\tContents intentionally not copied\n' "$config" >>"$mcp"
  fi
done

case "$platform" in
  apple)
    printf 'recommended\txcode-automation\tnative-fallback\txcodebuild and simctl remain available\n' >>"$mcp"
    ;;
  wordpress)
    printf 'optional\tcms-content-and-routes\trest-fallback\tREST API, sitemap, or fixtures\n' >>"$mcp"
    ;;
  shopify)
    printf 'optional\tcommerce-content\ttheme-cli-fallback\tDevelopment store and theme CLI\n' >>"$mcp"
    ;;
  web|static)
    printf 'optional\tbrowser-automation\tbuilt-in-fallback\tLocal URL capture and inspection\n' >>"$mcp"
    ;;
esac

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/	/\\t/g'
}

cat >"$output/project-context.json" <<EOF
{
  "schemaVersion": 1,
  "generatedBy": "openeditor-project-setup/generate-project-context.sh",
  "project": {
    "name": "$(json_escape "$project_name")",
    "root": "$(json_escape "$repo")",
    "platform": "$(json_escape "$platform")",
    "variant": "$(json_escape "$variant")",
    "compatibilityType": "$(json_escape "$compatibility_type")",
    "packageManager": "$(json_escape "$package_manager")",
    "runtimeLayout": "$(json_escape "$runtime_layout")",
    "graphArtifactCount": $graph_artifact_count
  },
  "confidence": "$(json_escape "$confidence")",
  "readiness": "$(json_escape "$readiness")"
}
EOF

cat >"$output/summary.md" <<EOF
# OpenEditor Project Context

- Project: $project_name
- Platform: $platform
- Variant: $variant
- Current compatibility type: $compatibility_type
- Confidence: $confidence
- Readiness: $readiness
- Package manager: $package_manager
- Runtime layout: $runtime_layout
- Graph artifacts: $graph_artifact_count

Generated context is read-only evidence. No packages were installed, no services were started, and MCP credential values were not inspected.
EOF

printf 'Generated OpenEditor context in %s\n' "$output"
