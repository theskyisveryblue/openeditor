#!/bin/sh
set -u

codex_installed=false
codex_authenticated=false
codex_method=none
claude_installed=false
claude_authenticated=false
claude_method=none
opencode_installed=false
opencode_authenticated=false
opencode_method=none

if command -v codex >/dev/null 2>&1; then
  codex_installed=true
  codex_status="$(codex login status 2>&1 || true)"
  if printf '%s' "$codex_status" | grep -qi 'logged in'; then
    codex_authenticated=true
  fi
  if printf '%s' "$codex_status" | grep -qi 'chatgpt'; then
    codex_method=chatgpt
  elif [ "$codex_authenticated" = true ]; then
    codex_method=authenticated
  fi
fi

if command -v opencode2 >/dev/null 2>&1; then
  opencode_installed=true
  if [ -f "${HOME}/.local/share/opencode/auth.json" ]; then
    opencode_authenticated=true
    opencode_method=authenticated
  fi
fi

if command -v claude >/dev/null 2>&1; then
  claude_installed=true
  claude_status="$(claude auth status --json 2>&1 || true)"
  if printf '%s' "$claude_status" | grep -Eq '"loggedIn"[[:space:]]*:[[:space:]]*true'; then
    claude_authenticated=true
  fi
  if [ "$claude_authenticated" = true ]; then
    claude_method=authenticated
  fi
fi

preferred="${OPENEDITOR_AGENT_PREFERENCE:-}"
case "$preferred" in
  codex)
    [ "$codex_authenticated" = true ] || preferred=""
    ;;
  claude)
    [ "$claude_authenticated" = true ] || preferred=""
    ;;
  opencode)
    [ "$opencode_authenticated" = true ] || preferred=""
    ;;
  *)
    preferred=""
    ;;
esac

if [ -z "$preferred" ]; then
  if [ "$codex_authenticated" = true ] && [ "$claude_authenticated" = false ] && [ "$opencode_authenticated" = false ]; then
    preferred=codex
  elif [ "$claude_authenticated" = true ] && [ "$codex_authenticated" = false ] && [ "$opencode_authenticated" = false ]; then
    preferred=claude
  elif [ "$opencode_authenticated" = true ] && [ "$codex_authenticated" = false ] && [ "$claude_authenticated" = false ]; then
    preferred=opencode
  fi
fi

needs_choice=false
authenticated_count=0
[ "$codex_authenticated" = true ] && authenticated_count=$((authenticated_count + 1))
[ "$claude_authenticated" = true ] && authenticated_count=$((authenticated_count + 1))
[ "$opencode_authenticated" = true ] && authenticated_count=$((authenticated_count + 1))
if [ "$authenticated_count" -gt 1 ] && [ -z "$preferred" ]; then
  needs_choice=true
fi

printf '{"codex":{"installed":%s,"authenticated":%s,"method":"%s"},"claude":{"installed":%s,"authenticated":%s,"method":"%s"},"opencode":{"installed":%s,"authenticated":%s,"method":"%s","experimental":true},"recommended":"%s","needsChoice":%s}\n' \
  "$codex_installed" "$codex_authenticated" "$codex_method" \
  "$claude_installed" "$claude_authenticated" "$claude_method" \
  "$opencode_installed" "$opencode_authenticated" "$opencode_method" \
  "$preferred" "$needs_choice"
