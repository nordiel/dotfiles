# dotfiles

My macOS setup, from a fresh Mac to ready-to-work in one command.

```sh
curl -fsSL https://raw.githubusercontent.com/nordiel/dotfiles/main/install.sh | bash
```

The script prompts for your password (for Homebrew) and may open the Xcode Command Line Tools installer. Apart from those two prompts it runs unattended. When it finishes, open **Ghostty**.

---

## What it does

`install.sh` runs these steps in order. Each step skips work that's already done, so running it again is safe.

| Step | Details |
|---|---|
| **Xcode Command Line Tools** | Provides `git`, compilers, and other basics |
| **Homebrew** | Installs everything in [`Brewfile`](Brewfile) |
| **Clone this repo** | Clones to `~/dotfiles` if it isn't there already |
| **Shell** | Oh My Zsh with the [Powerlevel10k](https://github.com/romkatv/powerlevel10k) theme |
| **Dotfiles** | Symlinks the configs (see [below](#whats-in-here)) |
| **Node** | [nvm](https://github.com/nvm-sh/nvm) with Node 18, 20 and 22 (default **18**) |
| **Python** | Python 3.14 via [uv](https://github.com/astral-sh/uv) |
| **Claude Code** | Native installer, into `~/.local/bin` |
| **VS Code** | Every extension in [`vscode/extensions.txt`](vscode/extensions.txt) |
| **SSH** | Generates `~/.ssh/id_ed25519` if it doesn't exist |
| **macOS** | Applies [`macos.sh`](macos.sh): Dock, trackpad, Rectangle |

### Apps & tools

**Apps:** Bitwarden · ChatGPT · DataGrip · Docker Desktop · Firefox · Fork · Ghostty · ngrok · Notion · Postgres.app · Rectangle · Slack · Spotify · Visual Studio Code

**CLI:** fastfetch · jq · kubectl · mysql-client · pandoc · rsync · uv

### macOS preferences

- Dock auto-hides, 56px icons, no recent apps
- Tap to click
- Rectangle uses its alternate default shortcuts

---

## What's in here

```
dotfiles/
├── install.sh            # the one command
├── macos.sh              # system preferences (defaults write ...)
├── Brewfile              # apps + CLI tools
├── home/                 # mirrors ~ — symlinked into place
│   ├── .zshrc  .zprofile  .p10k.zsh  .gitconfig
│   ├── .config/git/ignore
│   ├── .config/fastfetch/config.jsonc
│   └── .claude/          # Claude Code statusline + settings
├── ghostty/config.ghostty
└── vscode/
    ├── settings.json
    ├── snippets/
    └── extensions.txt
```

| Repo file | Lives at |
|---|---|
| `home/*` | `~/*` |
| `ghostty/config.ghostty` | `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty` |
| `vscode/settings.json`, `vscode/snippets/` | `~/Library/Application Support/Code/User/` |

The configs are **symlinks**, so editing `~/.zshrc` and the other linked files edits this repo directly. One exception: `~/.claude/settings.json` is copied once rather than linked, because Claude Code rewrites it.

If a real file was already where a link goes, the script moves it to `<file>.bak.<timestamp>` first. Nothing gets overwritten.

---

## Keeping it up to date

Linked configs update the repo directly. Commit and push those changes:

```sh
cd ~/dotfiles && git add -A && git commit -m "Update configs" && git push
```

Installed a new app or extension? Refresh the lists:

```sh
brew bundle dump --file=~/dotfiles/Brewfile --force --no-vscode
code --list-extensions > ~/dotfiles/vscode/extensions.txt
```

Changed a macOS setting you want to keep? Add a `defaults write` line to `macos.sh`. To find the key, run `defaults read <domain>` before and after the change and diff the output.

To install with a fork or a different location:

```sh
DOTFILES_REPO=https://github.com/you/dotfiles.git DOTFILES=~/code/dotfiles bash install.sh
```

---

## After installing

- [ ] Sign in to Bitwarden, Slack, Notion, Spotify, ChatGPT, Docker, and DataGrip
- [ ] Add `~/.ssh/id_ed25519.pub` to [GitHub](https://github.com/settings/keys) and Bitbucket
- [ ] Install Keynote, Pages, and Numbers from the App Store
- [ ] Run `claude` once to log in to Claude Code
- [ ] Log out and back in so every macOS setting takes effect

## Troubleshooting

- **The script stopped partway through.** Fix the problem and run `~/dotfiles/install.sh` again. Steps that already finished are skipped.
- **A VS Code extension failed.** The script prints a warning and keeps going. Install that extension from the Marketplace.
- **The prompt shows odd symbols.** Make sure you're in Ghostty, which ships with the icons Powerlevel10k needs. You can re-run `p10k configure` to tweak the prompt.
- **`brew` isn't found in a new terminal.** Open a new window. `.zprofile` loads Homebrew at login.
