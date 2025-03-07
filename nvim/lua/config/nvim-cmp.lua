local cmp = require("cmp")

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = function(fallback)
      if cmp.visible() then
        fallback() -- 補完が開いているときは Enter で確定しない
      else
        cmp.mapping.confirm({ select = false })() -- 通常の確定処理を適用
      end
    end,
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
  }),
})

