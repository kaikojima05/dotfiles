return {
  {
    "monaqa/dial.nvim",
    lazy = true,
    event = "BufRead",
    config = function()
      local augend = require("dial.augend")
      require("dial.config").augends:register_group({
        default = {
          augend.integer.alias.decimal, -- 10進数のインクリメント
          augend.integer.alias.hex, -- 16進数のインクリメント
          augend.date.alias["%Y/%m/%d"], -- 日付 (YYYY/MM/DD)
          augend.constant.alias.bool, -- true/false の切り替え
        },
      })

      vim.api.nvim_set_keymap("n", "<C-a>", require("dial.map").inc_normal(), { noremap = true, silent = true })
      vim.api.nvim_set_keymap("n", "<C-x>", require("dial.map").dec_normal(), { noremap = true, silent = true })
      vim.api.nvim_set_keymap("v", "<C-a>", require("dial.map").inc_visual(), { noremap = true, silent = true })
      vim.api.nvim_set_keymap("v", "<C-x>", require("dial.map").dec_visual(), { noremap = true, silent = true })
    end,
  },
}
