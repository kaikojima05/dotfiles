return {
  {
    "nvimdev/lspsaga.nvim",
    config = function()
      require("lspsaga").setup({
        symbol_in_winbar = {
          enable = false,
        },
        ui = {
          border = "single",
          title = false,
        },
        lightbulb = {
          enable = false,
        },
      })
    end,
  },
}
