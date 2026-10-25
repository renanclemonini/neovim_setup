return {
  "nvim-telescope/telescope.nvim",
  branch = "master",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<C-p>", function() require("telescope.builtin").find_files() end },
    { "<leader>fg", function() require("telescope.builtin").live_grep() end },
  },
}
