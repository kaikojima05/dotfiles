return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = { "hrsh7th/cmp-emoji" },
    config = function()
      local cmp = require("cmp")
      local lspkind = require("lspkind")

      cmp.setup({
        completion = {
          compleopt = "menu.menuone.preview.noselect",
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
        }),
        sources = {
          { name = "copilot" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        },
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol",
            max_width = 100,
          }),
        },
        window = {
          completion = {
            border = "rounded",
          },
          documentation = {
            border = "rounded",
            max_height = 10,
            max_width = 100,
          },
        },
      })
    end,
    opts = function(_, opts)
      table.insert(opts.sources, { name = "emoji" })
    end,
  },
}
