return {
  {
    "numToStr/Comment.nvim",
    config = function()
      vim.api.nvim_set_keymap("v", "co", "gc", { noremap = false, silent = true })
    end,
    lazy = false,
  },
}
