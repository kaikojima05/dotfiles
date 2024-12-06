return {
  {
    "tpope/vim-fugitive",
    event = "BufReadPre",
    config = function()
      -- Keymap for opening detailed git blame with commit messages
      vim.api.nvim_set_keymap("n", "<Leader>gb", ":Git blame<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("n", "<Leader>gd", ":Gdiffsplit<CR>", { noremap = true, silent = true })
    end,
  },
}
