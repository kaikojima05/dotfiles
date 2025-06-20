-- Safe Tailwind CSS configuration without cmp conflicts
return {
  -- Tailwind CSS Language Server
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.tailwindcss = {
        filetypes = {
          "css",
          "scss",
          "sass",
          "html",
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "vue",
          "svelte",
        },
        settings = {
          tailwindCSS = {
            classAttributes = { "class", "className", "classList", "ngClass" },
            lint = {
              cssConflict = "warning",
              invalidApply = "error",
              invalidConfigPath = "error",
              invalidScreen = "error",
              invalidTailwindDirective = "error",
              invalidVariant = "error",
              recommendedVariantOrder = "warning",
            },
            validate = true,
          },
        },
      }
      return opts
    end,
  },

  -- Tailwind CSS colorizer
  {
    "NvChad/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {
      filetypes = { "*" },
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        names = true,
        RRGGBBAA = false,
        AARRGGBB = false,
        rgb_fn = false,
        hsl_fn = false,
        css = false,
        css_fn = false,
        mode = "background",
        tailwind = true,
        sass = { enable = false },
        virtualtext = "■",
      },
      buftypes = {},
    },
  },

  -- Safe completion configuration for Tailwind
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    opts = function(_, opts)
      -- Ensure safe completion for tailwind without formatting conflicts
      opts = opts or {}
      opts.sources = opts.sources or {}
      
      -- Add tailwind completion source safely
      local tailwind_source = { name = "tailwindcss" }
      local has_tailwind = false
      
      for _, source in ipairs(opts.sources) do
        if source.name == "tailwindcss" then
          has_tailwind = true
          break
        end
      end
      
      if not has_tailwind then
        table.insert(opts.sources, tailwind_source)
      end
      
      return opts
    end,
  },
}