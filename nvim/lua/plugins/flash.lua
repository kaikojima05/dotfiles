return {
  {
    enabled = false,
    lazy = true,
    event = "BufRead",
    "folke/flash.nvim",
    ---@type Flash.Config
    opts = {
      search = {
        forward = true,
        multi_window = false,
        wrap = false,
        incremental = true,
      },
    },
  },
}
