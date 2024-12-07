return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
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
