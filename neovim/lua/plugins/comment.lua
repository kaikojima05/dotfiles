return {
  {
    "numToStr/Comment.nvim",
    lazy = true,
    event = "BufReadPre",
    config = function()
      vim.api.nvim_set_keymap("v", "co", "gc", { noremap = false, silent = true })
    end,
  },
}
