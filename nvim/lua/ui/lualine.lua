return {
  {
    "nvim-lualine/lualine.nvim",
    lazy = true,
    event = "UIEnter",
    opt = {
      options = {
        theme = "github-nvim-theme",
      },
      sections = {
        lualine_a = {
          "mode",
          fmt = function(str)
            return "%/Bold#" .. str
          end,
        },
      },
    },
  },
}
