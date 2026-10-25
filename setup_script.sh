#!/usr/bin/env bash
# Configura o Neovim do zero: lazy.nvim, monokai-pro, telescope, treesitter,
# neo-tree, LSP do Lua (mason + lspconfig + lazydev) e lualine.
#
# Uso normal:   ./setup-nvim.sh
# Teste isolado (não mexe na sua config real nem no sistema):
#   SKIP_SYSTEM=1 XDG_CONFIG_HOME=/tmp/t/config XDG_DATA_HOME=/tmp/t/data \
#   XDG_STATE_HOME=/tmp/t/state ./setup-nvim.sh
set -euo pipefail

NVIM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
SKIP_SYSTEM="${SKIP_SYSTEM:-0}"

log() { printf '\n==> %s\n' "$*"; }
die() { printf 'ERRO: %s\n' "$*" >&2; exit 1; }

# Grava stdin no arquivo indicado, criando as pastas necessárias
write() { mkdir -p "$(dirname "$1")"; cat > "$1"; }

[ "$(id -u)" -ne 0 ] || die "não rode como root"
command -v nvim >/dev/null || die "neovim não encontrado (precisa da versão 0.11 ou superior)"

# --- 1. Versão do Neovim -----------------------------------------------------
ver="$(nvim --version | head -1 | sed 's/^NVIM v//; s/-.*//')"
if [ "$(printf '%s\n0.11.0\n' "$ver" | sort -V | head -1)" != "0.11.0" ]; then
  die "Neovim $ver é antigo demais, a config usa vim.lsp.config (0.11+)"
fi
log "Neovim $ver ok"

# --- 2. Dependências do sistema ----------------------------------------------
if [ "$SKIP_SYSTEM" != "1" ]; then
  log "Instalando pacotes (git, curl, unzip, gcc, ripgrep, fontconfig)"
  sudo apt-get update
  sudo apt-get install -y git curl unzip build-essential ripgrep fontconfig

  if ! command -v tree-sitter >/dev/null; then
    [ "$(uname -m)" = "x86_64" ] || die "tree-sitter CLI: este script só baixa o binário x86_64"
    log "Instalando tree-sitter CLI"
    curl -fsSL https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz \
      | gunzip > /tmp/tree-sitter
    sudo install -m 755 /tmp/tree-sitter /usr/local/bin/tree-sitter
    rm -f /tmp/tree-sitter
  fi

  if ! fc-list | grep -qi "JetBrainsMono Nerd"; then
    log "Instalando JetBrainsMono Nerd Font"
    mkdir -p "$HOME/.local/share/fonts"
    curl -fsSL -o /tmp/JetBrainsMono.zip \
      https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    unzip -oq /tmp/JetBrainsMono.zip -d "$HOME/.local/share/fonts/JetBrainsMono"
    rm -f /tmp/JetBrainsMono.zip
    fc-cache -f
  fi
fi

for cmd in git tree-sitter gcc rg; do
  command -v "$cmd" >/dev/null || die "'$cmd' não encontrado no PATH"
done

# --- 3. Backup da config existente -------------------------------------------
if [ -e "$NVIM_DIR" ]; then
  backup="$NVIM_DIR.bak-$(date +%Y%m%d%H%M%S)"
  log "Config existente movida para $backup"
  mv "$NVIM_DIR" "$backup"
fi

# --- 4. Arquivos da configuração ---------------------------------------------
log "Gravando arquivos em $NVIM_DIR"

write "$NVIM_DIR/init.lua" <<'LUA'
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("vim-options")
require("lazy").setup("plugins")
LUA

write "$NVIM_DIR/lua/vim-options.lua" <<'LUA'
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.g.mapleader = " "
LUA

write "$NVIM_DIR/lua/plugins/monokai.lua" <<'LUA'
return {
  "loctvl842/monokai-pro.nvim",
  priority = 1000,
  config = function()
    vim.cmd.colorscheme("monokai-pro")
  end,
}
LUA

write "$NVIM_DIR/lua/plugins/telescope.lua" <<'LUA'
return {
  "nvim-telescope/telescope.nvim",
  branch = "master",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<C-p>", function() require("telescope.builtin").find_files() end },
    { "<leader>fg", function() require("telescope.builtin").live_grep() end },
  },
}
LUA

write "$NVIM_DIR/lua/plugins/treesitter.lua" <<'LUA'
return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").install({ "lua", "python", "bash", "dockerfile", "yaml", "json" })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "lua", "python", "bash", "sh", "dockerfile", "yaml", "json" },
      callback = function()
        vim.treesitter.start()
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
LUA

write "$NVIM_DIR/lua/plugins/neo-tree.lua" <<'LUA'
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  lazy = false,
  keys = {
    { "<leader>e", ":Neotree position=right focus<CR>" },
    { "<leader>E", ":Neotree position=right close<CR>" },
  },
}
LUA

write "$NVIM_DIR/lua/plugins/lsp-config.lua" <<'LUA'
return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls" },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
          },
        },
      })
      vim.lsp.enable("lua_ls")
    end,
  },
}
LUA

write "$NVIM_DIR/lua/plugins/lazydev.lua" <<'LUA'
return {
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
  },
}
LUA

write "$NVIM_DIR/lua/plugins/lualine.lua" <<'LUA'
return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = { theme = "auto" },
  },
}
LUA

# --- 5. Repositório git (o lua_ls usa o .git como raiz do projeto) -----------
log "Iniciando repositório git em $NVIM_DIR"
git -C "$NVIM_DIR" init -q -b main

# --- 6. Instala os plugins sem abrir a interface -----------------------------
log "Instalando plugins (lazy.nvim)"
nvim --headless "+Lazy! sync" +qa

# --- 7. Commit inicial (não falha o script se não houver identidade git) -----
git -C "$NVIM_DIR" add -A
git -C "$NVIM_DIR" commit -q -m "feat: initial neovim config" \
  || echo "Aviso: commit não feito (configure git user.name e user.email)."

log "Pronto."
cat <<'MSG'

Faltam dois passos manuais:
  1. Tilix: Preferências > Perfil > Geral > Fonte personalizada >
     JetBrainsMono Nerd Font Mono (Regular, 13).
  2. Abra o nvim uma vez e espere terminar: o Mason baixa o lua-language-server
     e o Treesitter compila os parsers (acompanhe com :Mason e :messages).

Conferência: :Lazy, :Mason e :checkhealth vim.lsp (com um arquivo .lua aberto).
MSG
