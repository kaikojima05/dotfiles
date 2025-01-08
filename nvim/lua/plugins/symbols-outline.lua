return {
  {
    "simrat39/symbols-outline.nvim",
    lazy = true,
    event = "BufRead",
    keys = { { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } },
    cmd = "SymbolsOutline",
    opts = {
      position = "right",
    },
  },
}