return {
  {
    "nvimdev/lspsaga.nvim",
    lazy = true,
    event = "BufRead",
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
