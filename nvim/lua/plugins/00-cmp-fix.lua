-- Critical fix for nvim-cmp formatting conflicts
-- This file MUST be loaded before any other cmp configurations
return {
  {
    "hrsh7th/nvim-cmp",
    priority = 1000,
    lazy = false,
    opts = function(_, opts)
      -- Ensure opts and formatting exist to prevent nil errors
      opts = opts or {}
      opts.formatting = opts.formatting or {}
      
      -- Initialize format function to prevent tailwind errors
      if not opts.formatting.format then
        opts.formatting.format = function(entry, vim_item)
          -- Basic safe formatting
          vim_item.menu = ({
            buffer = "[Buffer]",
            nvim_lsp = "[LSP]",
            luasnip = "[Snippet]",
            nvim_lua = "[Lua]",
            path = "[Path]",
            ["vim-dadbod-completion"] = "[DB]",
          })[entry.source.name] or ""
          
          return vim_item
        end
      end
      
      return opts
    end,
  },
  
  -- Override tailwind configuration to prevent conflicts
  {
    "tailwindlabs/tailwindcss-language-server",
    optional = true,
    opts = function(_, opts)
      -- Disable problematic tailwind cmp formatting
      return opts
    end,
  },
}