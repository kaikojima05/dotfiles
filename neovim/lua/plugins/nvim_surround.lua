return {
  {
    "kylechui/nvim-surround",
    lazy = true,
    event = "BufRead",
    version = "*",
    config = function()
      require("nvim-surround").setup({})
    end,
  },
}
