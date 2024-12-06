return {
  {
    "folke/zen-mode.nvim",
    config = function()
      require("zen-mode").setup({
        window = {
          width = 130,
          height = 1,
          options = {
            signcolumn = "no",
            number = false,
            relativenumber = false,
            cursorline = false,
            foldcolumn = "0",
            list = false,
          },
        },
        plugins = {
          gitsigns = { enabled = false },
          tmux = { enabled = false },
          twilight = { enabled = false },
        },
      })

      -- keymap
      vim.api.nvim_set_keymap("n", ":zen", ":ZenMode<CR>", { noremap = true, silent = true })
    end,
  },
}
