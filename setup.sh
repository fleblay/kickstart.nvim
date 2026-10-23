#!/usr/bin/env bash
#
# Bootstrap this Neovim config on a fresh macOS machine:
#   installs Homebrew (if missing) and all dependencies, symlinks the repo
#   to ~/.config/nvim, then installs plugins, LSP servers and parsers.
#
# Idempotent: safe to re-run at any time.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

# 1. Homebrew
if ! command -v brew >/dev/null 2>&1; then
  step "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# 2. Dependencies
step "Installing dependencies (brew bundle)"
# Newer Homebrew refuses formulas from untrusted third-party taps
brew tap --quiet hashicorp/tap 2>/dev/null || true
brew trust hashicorp/tap 2>/dev/null || true
brew bundle --file "$REPO_DIR/Brewfile"

# Mason needs brew's node (>= 18) to shadow any older system install
node_path="$(command -v node)"
case "$node_path" in
  /opt/homebrew/*) ;;
  *) echo "WARNING: node resolves to $node_path — make sure /opt/homebrew/bin comes first in PATH" ;;
esac

# 3. Symlink config
step "Linking $NVIM_CONFIG -> $REPO_DIR"
if [ -e "$NVIM_CONFIG" ] && [ "$(readlink "$NVIM_CONFIG" || true)" != "$REPO_DIR" ]; then
  backup="$NVIM_CONFIG.bak.$(date +%Y%m%d%H%M%S)"
  echo "Backing up existing config to $backup"
  mv "$NVIM_CONFIG" "$backup"
fi
[ -L "$NVIM_CONFIG" ] || ln -s "$REPO_DIR" "$NVIM_CONFIG"

# 4. First boot: vim.pack clones all plugins synchronously.
#    stdin from /dev/null makes the install prompt proceed non-interactively.
step "Installing plugins (first headless boot)"
nvim --headless "+qa" </dev/null

# 5. LSP servers/tools (Mason) and treesitter parsers, synchronously
step "Installing LSP servers, tools and treesitter parsers"
nvim --headless \
  "+MasonToolsInstallSync" \
  "+lua require('nvim-treesitter').install(vim.g.kickstart_parsers):wait(600000)" \
  "+qa" </dev/null

step "Done"
cat <<'EOF'

Next steps:
  1. Set your terminal font to "JetBrainsMono Nerd Font"
  2. Open nvim and run :checkhealth
  3. Update plugins later with :lua vim.pack.update()  — tools with :Mason
EOF
