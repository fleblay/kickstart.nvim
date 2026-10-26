#!/usr/bin/env bash
#
# Bootstrap this Neovim config on a fresh macOS machine:
#   installs Homebrew (if missing) and all packages, symlinks the repo
#   to ~/.config/nvim and the tmux and Ghostty configs into place, then
#   installs plugins, LSP servers and parsers.
#
# Idempotent: safe to re-run at any time.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
NVIM_CONFIG="$CONFIG_HOME/nvim"

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

# link <src> <dest>: symlink dest -> src, backing up whatever is in the way
link() {
  local src="$1" dest="$2"
  [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ] && return
  echo "Linking $dest -> $src"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    local backup
    backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
    echo "  backing up existing $dest to $backup"
    mv "$dest" "$backup"
  fi
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
}

# 1. Homebrew
if ! command -v brew >/dev/null 2>&1; then
  step "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# 2. Dependencies
step "Installing dependencies (brew bundle)"
brew bundle --file "$REPO_DIR/Brewfile"

# Mason needs brew's node (>= 18) to shadow any older system install
node_path="$(command -v node)"
case "$node_path" in
  /opt/homebrew/*) ;;
  *) echo "WARNING: node resolves to $node_path — make sure /opt/homebrew/bin comes first in PATH" ;;
esac

# 3. Symlink configs
step "Linking configs"
link "$REPO_DIR" "$NVIM_CONFIG"
link "$REPO_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
link "$REPO_DIR/ghostty/config.ghostty" "$CONFIG_HOME/ghostty/config.ghostty"

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
  1. Reload tmux if it is running: tmux source-file ~/.tmux.conf
  2. Open nvim and run :checkhealth
  3. Update plugins later with :lua vim.pack.update()  — tools with :Mason
EOF
