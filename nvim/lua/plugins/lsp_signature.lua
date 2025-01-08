return {
  {
    "ray-x/lsp_signature.nvim",
    lazy = true,
    event = "BufRead",
    opts = {},
    config = function()
      require("lsp_signature").setup({
        hint_enable = false,
      })
    end,
  },
}
