#!/usr/bin/env bash
# One-shot Mac setup. Safe to re-run: every step skips what's already done.
#
#   Fresh Mac:  curl -fsSL https://raw.githubusercontent.com/$GITHUB_USER/dotfiles/main/install.sh | bash
#   Local:      ~/dotfiles/install.sh
set -euo pipefail

DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/CHANGE_ME/dotfiles.git}"
DOTFILES="${DOTFILES:-$HOME/dotfiles}"
NODE_VERSIONS=(18 20 22)
NODE_DEFAULT=18
NVM_VERSION=v0.40.3

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

# Symlink $1 (in repo) to $2, backing up whatever real file was there.
link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then return; fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mv "$dst" "$dst.bak.$(date +%Y%m%d%H%M%S)"
  fi
  ln -s "$src" "$dst"
  echo "linked $dst"
}

step "Xcode Command Line Tools"
if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
  echo "Finish the installer dialog; waiting..."
  until xcode-select -p >/dev/null 2>&1; do sleep 5; done
fi

step "Homebrew"
if ! command -v brew >/dev/null 2>&1 && [ ! -x /opt/homebrew/bin/brew ]; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

step "Dotfiles repo"
if [ ! -d "$DOTFILES/.git" ]; then
  git clone "$DOTFILES_REPO" "$DOTFILES"
fi

step "Brew bundle"
brew bundle --file="$DOTFILES/Brewfile"

step "Oh My Zsh + Powerlevel10k"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
P10K="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
[ -d "$P10K" ] || git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K"

step "Link dotfiles"
link "$DOTFILES/home/.zshrc"                       "$HOME/.zshrc"
link "$DOTFILES/home/.zprofile"                    "$HOME/.zprofile"
link "$DOTFILES/home/.p10k.zsh"                    "$HOME/.p10k.zsh"
link "$DOTFILES/home/.gitconfig"                   "$HOME/.gitconfig"
link "$DOTFILES/home/.config/git/ignore"           "$HOME/.config/git/ignore"
link "$DOTFILES/home/.config/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
link "$DOTFILES/home/.claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
link "$DOTFILES/ghostty/config.ghostty" \
  "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
VSCODE_USER="$HOME/Library/Application Support/Code/User"
link "$DOTFILES/vscode/settings.json" "$VSCODE_USER/settings.json"
for f in "$DOTFILES"/vscode/snippets/*; do link "$f" "$VSCODE_USER/snippets/$(basename "$f")"; done
# Claude Code rewrites its settings file, so seed a copy instead of linking.
[ -e "$HOME/.claude/settings.json" ] || cp "$DOTFILES/home/.claude/settings.json" "$HOME/.claude/settings.json"

step "Node (nvm)"
export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  PROFILE=/dev/null bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh)"
fi
set +u; . "$NVM_DIR/nvm.sh"
for v in "${NODE_VERSIONS[@]}"; do nvm install "$v"; done
nvm alias default "$NODE_DEFAULT"
set -u

step "Python (uv)"
uv python install 3.14

step "Claude Code"
command -v claude >/dev/null 2>&1 || [ -x "$HOME/.local/bin/claude" ] \
  || curl -fsSL https://claude.ai/install.sh | bash

step "VS Code extensions"
CODE="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
installed="$("$CODE" --list-extensions | tr '[:upper:]' '[:lower:]')"
while read -r ext; do
  [ -z "$ext" ] && continue
  grep -qx "$ext" <<<"$installed" || "$CODE" --install-extension "$ext" || echo "warn: $ext failed"
done < "$DOTFILES/vscode/extensions.txt"

step "SSH key"
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  ssh-keygen -t ed25519 -C "$(git config --global user.email)" -f "$HOME/.ssh/id_ed25519" -N ""
  echo "New public key (add it to GitHub/Bitbucket):"
  cat "$HOME/.ssh/id_ed25519.pub"
fi

step "macOS defaults"
bash "$DOTFILES/macos.sh"

step "Done. Open Ghostty to start using the new shell."
