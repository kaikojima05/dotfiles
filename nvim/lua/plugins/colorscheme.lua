return {
  {
    "projekt0n/github-nvim-theme",
    lazy = true,
    priority = 1000,
    config = function()
      require("github-theme").setup({
        options = {
          transparent = true,
        },
        groups = {
          all = {
            -- フローティングウィンドウに背景色を設定
            NormalFloat = { bg = "#2d333b" },
            FloatBorder = { fg = "#545d68", bg = "#2d333b" },
          },
        },
      })
    end,
  },
}
