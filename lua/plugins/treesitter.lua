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
