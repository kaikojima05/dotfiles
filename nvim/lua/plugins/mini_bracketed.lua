return {
  {
    "echasnovski/mini.bracketed",
    lazy = true,
    event = "InsertEnter",
    config = function()
      local bracketed = require("mini.bracketed")
      bracketed.setup({
        indent = { suffix = "a" },
        file = { suffix = "" },
        window = { suffix = "" },
        quickfix = { suffix = "" },
        yank = { suffix = "" },
        treesitter = { suffix = "n" },
      })
    end,
  },
}
