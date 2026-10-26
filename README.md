# dotfiles

My Mac setup in one command.

## New Mac

```sh
curl -fsSL https://raw.githubusercontent.com/nordiel/dotfiles/main/install.sh | bash
```

It installs the Xcode CLT, Homebrew, everything in `Brewfile`, Oh My Zsh with Powerlevel10k, nvm (Node 18/20/22, default 18), Python 3.14 via uv, Claude Code, and the VS Code extensions. It also symlinks the configs below, creates an SSH key if one is missing, and applies `macos.sh`.

Re-running it is safe. Any file it replaces is first saved as `*.bak.<timestamp>`.

## What lives where

| Repo path | Linked to |
|---|---|
| `home/.zshrc`, `.zprofile`, `.p10k.zsh`, `.gitconfig` | `~/` |
| `home/.config/git/ignore`, `home/.config/fastfetch/config.jsonc` | `~/.config/...` |
| `home/.claude/statusline-command.sh` | `~/.claude/` (`settings.json` is copied once, not linked) |
| `ghostty/config.ghostty` | `~/Library/Application Support/com.mitchellh.ghostty/` |
| `vscode/settings.json`, `vscode/snippets/` | `~/Library/Application Support/Code/User/` |

The configs are symlinks, so editing `~/.zshrc` and other linked files edits this repo directly. Commit and push those changes.

## Keeping it current

```sh
brew bundle dump --file=~/dotfiles/Brewfile --force --no-vscode   # after installing new brew apps
code --list-extensions > ~/dotfiles/vscode/extensions.txt         # after adding VS Code extensions
```

## Manual steps afterwards

- Sign in to Bitwarden, Slack, Notion, Spotify, ChatGPT, Docker, and DataGrip.
- Add `~/.ssh/id_ed25519.pub` to GitHub and Bitbucket.
- Install Keynote, Pages, and Numbers from the App Store.
