# neovim_setup

[English](README.md) | Português (Brasil)

> A versão em inglês é a canônica. Ao alterar o conteúdo, atualize os dois arquivos.

Script de bootstrap e configuração do Neovim para um setup Lua pequeno e opinativo.

Plugins incluídos:

- [lazy.nvim](https://github.com/folke/lazy.nvim) — gerenciador de plugins
- [monokai-pro.nvim](https://github.com/loctvl842/monokai-pro.nvim) — colorscheme
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) — fuzzy finder
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) — realce de sintaxe e indentação
- [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) — explorador de arquivos
- [mason.nvim](https://github.com/williamboman/mason.nvim) + [mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim) + [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) — ferramentas de LSP
- [lazydev.nvim](https://github.com/folke/lazydev.nvim) — suporte ao desenvolvimento em Lua
- [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) — statusline

## Requisitos

- Linux com `apt` (Debian/Ubuntu ou derivado) e acesso a `sudo`
- Neovim **0.11 ou mais recente** — a configuração usa `vim.lsp.config` / `vim.lsp.enable`
- Arquitetura `x86_64` se a CLI `tree-sitter` ainda não estiver instalada (o script só baixa o binário x86_64)
- `git`
- Acesso à rede para o GitHub na primeira execução (plugins, fontes, CLI do tree-sitter)

O script se recusa a rodar como `root`.

## Passo 1 — Clone em `~/.config/nvim`

A configuração precisa ficar no diretório de configuração do Neovim:

```bash
git clone git@github.com:renanclemonini/neovim_setup.git ~/.config/nvim
cd ~/.config/nvim
```

Se você clonou em outro lugar, mova ou clone de novo para que o caminho final seja
`~/.config/nvim`.

## Passo 2 — Execute o instalador

```bash
chmod +x setup_script.sh
./setup_script.sh
```

O que acontece em seguida:

1. Verifica se o Neovim está instalado e se é pelo menos a versão 0.11.
2. Instala pacotes do sistema: `git`, `curl`, `unzip`, `build-essential`, `ripgrep`, `fontconfig`.
3. Instala a CLI `tree-sitter` se estiver faltando.
4. Instala a fonte JetBrainsMono Nerd Font em `~/.local/share/fonts` se estiver faltando.
5. Faz backup de qualquer `~/.config/nvim` existente para `~/.config/nvim.bak-<timestamp>`.
6. Grava os arquivos de configuração (`init.lua`, `lua/**`).
7. Executa `git init -b main` no diretório de configuração.
8. Instala os plugins com `nvim --headless "+Lazy! sync" +qa`.
9. Cria um commit inicial. Se `git user.name` / `user.email` não estiverem definidos,
   o commit é ignorado com um aviso e o script ainda termina com sucesso.

Importante: o script reconstrói a configuração por conta própria. Se você clonou
este repositório diretamente em `~/.config/nvim`, o clone é movido para
`~/.config/nvim.bak-<timestamp>` no passo 5 e o script grava uma cópia nova dos
mesmos arquivos, seguida de um novo `git init`. Guarde o backup se quiser recuperar
o histórico ou o remote do clone original.

### Flags opcionais

Pular a instalação de pacotes do sistema e de fontes (útil quando as dependências
já existem):

```bash
SKIP_SYSTEM=1 ./setup_script.sh
```

Execução de teste em diretórios descartáveis, sem tocar na sua configuração real
nem no sistema:

```bash
SKIP_SYSTEM=1 \
  XDG_CONFIG_HOME=/tmp/t/config \
  XDG_DATA_HOME=/tmp/t/data \
  XDG_STATE_HOME=/tmp/t/state \
  ./setup_script.sh
```

Não rode como `root`.

## Após a instalação

Restam dois passos manuais:

1. **Fonte do terminal** — selecione `JetBrainsMono Nerd Font Mono` (Regular, 13)
   no perfil do seu terminal. Exemplo para Tilix: Preferências > Perfil > Geral >
   Fonte personalizada.
2. **Primeira execução** — abra o `nvim` uma vez e deixe terminar. O Mason baixa o
   `lua-language-server` e o Treesitter compila os parsers. Acompanhe o progresso
   com `:Mason` e `:messages`.

## Keymaps

A tecla leader é `Space`.

| Tecla | Ação |
| --- | --- |
| `<C-p>` | Buscar arquivos (Telescope) |
| `<leader>fg` | Busca ao vivo / live grep (Telescope) |
| `<leader>e` | Abrir o Neo-tree à direita e focar nele |
| `<leader>E` | Fechar o Neo-tree |

O realce e a indentação do Treesitter estão habilitados para `lua`, `python`,
`bash`, `sh`, `dockerfile`, `yaml` e `json`.

## Verificar a instalação

```vim
:Lazy          " interface do gerenciador de plugins
:Mason         " language servers instalados
:messages      " erros e saída de build
:checkhealth vim.lsp
```

Rode `:checkhealth vim.lsp` com um arquivo `.lua` aberto para que o `lua_ls`
se conecte.

## Solução de problemas

| Sintoma | Correção |
| --- | --- |
| `neovim não encontrado` | Instale o Neovim 0.11+ e garanta que `nvim` está no `PATH`. |
| `Neovim X is too old` | Atualize para 0.11 ou mais recente; o script aborta em versões antigas. |
| `tree-sitter CLI: this script only downloads the x86_64 binary` | Instale `tree-sitter` manualmente ou rode em `x86_64`. |
| `'rg' não encontrado` / `'gcc' não encontrado` | Rode de novo sem `SKIP_SYSTEM=1`, ou instale `ripgrep` / `build-essential`. |
| Commit inicial ignorado | Defina `git config --global user.name` e `user.email`, depois faça o commit manualmente. |
| Mason ou Treesitter falha na primeira execução | Verifique o acesso à rede, depois use `:Mason` / `:TSUpdate` e reabra o Neovim. |
| Ícones quebrados | Instale a Nerd Font e selecione-a no perfil do terminal. |

## Restaurar uma configuração anterior

O instalador mantém a configuração anterior em um backup com timestamp:

```bash
ls -d ~/.config/nvim.bak-*
mv ~/.config/nvim ~/.config/nvim.broken
mv ~/.config/nvim.bak-<timestamp> ~/.config/nvim
```

## Notas de segurança

Este repositório não contém credenciais, tokens ou chaves privadas, e o remote do
git usa SSH em vez de um token embutido. Mantenha assim:

- Nunca faça commit de tokens de API, senhas, arquivos `.env` ou chaves privadas.
- Não cole segredos em configurações de plugins nem no `lazy-lock.json`.
- O histórico de commits inclui o endereço de e-mail do autor; reescreva o histórico
  se precisar removê-lo antes de publicar.

Considere adicionar `.env`, `*.key` e `*.pem` ao `.gitignore` se começar a manter
arquivos próximos de segredos neste repositório.
