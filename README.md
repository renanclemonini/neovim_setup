# neovim_setup

English | [Português (Brasil)](README.pt-br.md)

A bootstrap script and Neovim configuration for a small, opinionated Lua setup.

Bundled plugins:

- [lazy.nvim](https://github.com/folke/lazy.nvim) — plugin manager
- [monokai-pro.nvim](https://github.com/loctvl842/monokai-pro.nvim) — colorscheme
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) — fuzzy finder
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) — syntax highlighting and indentation
- [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) — file explorer
- [mason.nvim](https://github.com/williamboman/mason.nvim) + [mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim) + [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) — LSP tooling
- [lazydev.nvim](https://github.com/folke/lazydev.nvim) — Lua development support
- [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) — statusline

## Requirements

- Linux on `apt` (Debian/Ubuntu or a derivative) with `sudo` access
- Neovim **0.11 or newer** — the config uses `vim.lsp.config` / `vim.lsp.enable`
- `x86_64` architecture if the `tree-sitter` CLI is not already installed (the script only downloads the x86_64 binary)
- `git`
- Network access to GitHub during the first run (plugins, fonts, tree-sitter CLI)

The script refuses to run as `root`.

## Step 1 — Clone into `~/.config/nvim`

The configuration must live in Neovim's config directory:

```bash
git clone git@github.com:renanclemonini/neovim_setup.git ~/.config/nvim
cd ~/.config/nvim
```

If you cloned somewhere else, move or clone it again so that the final path is
`~/.config/nvim`.

## Step 2 — Run the installer

```bash
chmod +x setup_script.sh
./setup_script.sh
```

What happens next:

1. Checks that Neovim is installed and at least version 0.11.
2. Installs system packages: `git`, `curl`, `unzip`, `build-essential`, `ripgrep`, `fontconfig`.
3. Installs the `tree-sitter` CLI if missing.
4. Installs the JetBrainsMono Nerd Font into `~/.local/share/fonts` if missing.
5. Backs up any existing `~/.config/nvim` to `~/.config/nvim.bak-<timestamp>`.
6. Writes the configuration files (`init.lua`, `lua/**`).
7. Runs `git init -b main` in the config directory.
8. Installs plugins with `nvim --headless "+Lazy! sync" +qa`.
9. Creates an initial commit. If `git user.name` / `user.email` are not set, the
   commit is skipped with a warning and the script still succeeds.

Important: the script rebuilds the configuration itself. If you cloned this repo
directly into `~/.config/nvim`, the clone is moved to
`~/.config/nvim.bak-<timestamp>` in step 5 and the script writes a fresh copy of
the same files, followed by a new `git init`. Keep the backup if you want to
recover the original clone's history or remote.

### Optional flags

Skip system package and font installation (useful when dependencies already
exist):

```bash
SKIP_SYSTEM=1 ./setup_script.sh
```

Dry run against throwaway directories without touching your real config or the
system:

```bash
SKIP_SYSTEM=1 \
  XDG_CONFIG_HOME=/tmp/t/config \
  XDG_DATA_HOME=/tmp/t/data \
  XDG_STATE_HOME=/tmp/t/state \
  ./setup_script.sh
```

Do not run as `root`.

## After installation

Two manual steps remain:

1. **Terminal font** — select `JetBrainsMono Nerd Font Mono` (Regular, 13) in
   your terminal profile. Example for Tilix: Preferences > Profile > General >
   Custom font.
2. **First launch** — open `nvim` once and let it finish. Mason downloads
   `lua-language-server` and Treesitter compiles the parsers. Watch progress
   with `:Mason` and `:messages`.

## Keymaps

Leader key is `Space`.

| Key | Action |
| --- | --- |
| `<C-p>` | Find files (Telescope) |
| `<leader>fg` | Live grep (Telescope) |
| `<leader>e` | Open Neo-tree on the right and focus it |
| `<leader>E` | Close Neo-tree |

Treesitter highlighting and indentation are enabled for `lua`, `python`, `bash`,
`sh`, `dockerfile`, `yaml`, and `json`.

## Verify the setup

```vim
:Lazy          " plugin manager UI
:Mason         " installed language servers
:messages      " errors and build output
:checkhealth vim.lsp
```

Run `:checkhealth vim.lsp` with a `.lua` file open so `lua_ls` attaches.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| `neovim não encontrado` | Install Neovim 0.11+ and make sure `nvim` is on `PATH`. |
| `Neovim X is too old` | Upgrade to 0.11 or newer; the script aborts on older versions. |
| `tree-sitter CLI: this script only downloads the x86_64 binary` | Install `tree-sitter` manually or run on `x86_64`. |
| `'rg' não encontrado` / `'gcc' não encontrado` | Re-run without `SKIP_SYSTEM=1`, or install `ripgrep` / `build-essential`. |
| Initial commit skipped | Set `git config --global user.name` and `user.email`, then commit manually. |
| Mason or Treesitter fails on first launch | Check network access, then `:Mason` / `:TSUpdate` and re-open Neovim. |
| Icons look broken | Install the Nerd Font and select it in your terminal profile. |

## Restore a previous configuration

The installer keeps the previous config in a timestamped backup:

```bash
ls -d ~/.config/nvim.bak-*
mv ~/.config/nvim ~/.config/nvim.broken
mv ~/.config/nvim.bak-<timestamp> ~/.config/nvim
```

## Security notes

This repository contains no credentials, tokens, or private keys, and the git
remote uses SSH rather than an embedded token. Keep it that way:

- Never commit API tokens, passwords, `.env` files, or private keys.
- Do not paste secrets into plugin configs or `lazy-lock.json`.
- The commit history includes the author's email address; rewrite history if you
  need to remove it before publishing.

Consider adding `.env`, `*.key`, and `*.pem` to `.gitignore` if you start keeping
secrets-adjacent files in this repository.
