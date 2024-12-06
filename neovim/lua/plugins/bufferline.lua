return {
  {
    "akinsho/bufferline.nvim",
    depends = { "kyazdani42/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          separator_style = "slant",
          show_buffer_close_icons = false,
          show_close_icon = false,
        },
        fill = {
          guibg = "#181c24",
        },
      })

      -- delete default keymaps
      vim.api.nvim_del_keymap("n", "H")
      vim.api.nvim_del_keymap("n", "L")
    end, -- end,
  },
}
