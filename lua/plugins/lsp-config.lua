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
        ensure_installed = { "lua_ls", "pyright", "ruff" },
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
      vim.lsp.enable({ "lua_ls", "pyright", "ruff" })
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
      vim.keymap.set({ "n", "v" }, "gra", vim.lsp.buf.code_action, {})
      vim.keymap.set("n", "<leader>gf", function()
        vim.lsp.buf.format({
          filter = function(client)
            return client.name ~= "ruff"
          end,
        })
      end, {})
    end,
  },
}
