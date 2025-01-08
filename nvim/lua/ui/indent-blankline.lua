return {
  {
    "lukas-reineke/indent-blankline.nvim",
    lazy = true,
    event = "UIEnter",
    main = "ibl",
    opts = {
      indent = {
        char = "┃", -- 太い縦棒
      },
      scope = {
        enabled = true,
        show_start = true,
        show_end = false,
      },
    },
  },
}
