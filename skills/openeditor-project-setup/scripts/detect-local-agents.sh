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
zed_installed=false
zed_authenticated=false
zed_method=none

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

# Zed's agent auth lives in the OS keychain / app data, so only the binary
# presence and a best-effort app-data signal are reported here.
if command -v zed >/dev/null 2>&1; then
  zed_installed=true
  zed_method=installed
  if [ -n "$(ls -A "${HOME}/.local/share/zed" 2>/dev/null)" ] || [ -n "$(ls -A "${HOME}/.config/zed" 2>/dev/null)" ]; then
    zed_authenticated=true
    zed_method=app-data
  fi
fi

hunk_available=false
lazygit_available=false
lazyworktree_available=false
nvim_available=false
command -v hunk >/dev/null 2>&1 && hunk_available=true
command -v lazygit >/dev/null 2>&1 && lazygit_available=true
command -v lazyworktree >/dev/null 2>&1 && lazyworktree_available=true
command -v nvim >/dev/null 2>&1 && nvim_available=true

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
  zed)
    [ "$zed_authenticated" = true ] || preferred=""
    ;;
  *)
    preferred=""
    ;;
esac

if [ -z "$preferred" ]; then
  if [ "$codex_authenticated" = true ] && [ "$claude_authenticated" = false ] && [ "$opencode_authenticated" = false ] && [ "$zed_authenticated" = false ]; then
    preferred=codex
  elif [ "$claude_authenticated" = true ] && [ "$codex_authenticated" = false ] && [ "$opencode_authenticated" = false ] && [ "$zed_authenticated" = false ]; then
    preferred=claude
  elif [ "$opencode_authenticated" = true ] && [ "$codex_authenticated" = false ] && [ "$claude_authenticated" = false ] && [ "$zed_authenticated" = false ]; then
    preferred=opencode
  elif [ "$zed_authenticated" = true ] && [ "$codex_authenticated" = false ] && [ "$claude_authenticated" = false ] && [ "$opencode_authenticated" = false ]; then
    preferred=zed
  fi
fi

needs_choice=false
authenticated_count=0
[ "$codex_authenticated" = true ] && authenticated_count=$((authenticated_count + 1))
[ "$claude_authenticated" = true ] && authenticated_count=$((authenticated_count + 1))
[ "$opencode_authenticated" = true ] && authenticated_count=$((authenticated_count + 1))
[ "$zed_authenticated" = true ] && authenticated_count=$((authenticated_count + 1))
if [ "$authenticated_count" -gt 1 ] && [ -z "$preferred" ]; then
  needs_choice=true
fi

printf '{"codex":{"installed":%s,"authenticated":%s,"method":"%s"},"claude":{"installed":%s,"authenticated":%s,"method":"%s"},"opencode":{"installed":%s,"authenticated":%s,"method":"%s","experimental":true},"zed":{"installed":%s,"authenticated":%s,"method":"%s","experimental":true},"tools":{"hunk":%s,"lazygit":%s,"lazyworktree":%s,"nvim":%s},"recommended":"%s","needsChoice":%s}\n' \
  "$codex_installed" "$codex_authenticated" "$codex_method" \
  "$claude_installed" "$claude_authenticated" "$claude_method" \
  "$opencode_installed" "$opencode_authenticated" "$opencode_method" \
  "$zed_installed" "$zed_authenticated" "$zed_method" \
  "$hunk_available" "$lazygit_available" "$lazyworktree_available" "$nvim_available" \
  "$preferred" "$needs_choice"
