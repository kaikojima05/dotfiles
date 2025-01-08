return {
  { "nvim-treesitter/playground", cmd = "TSPlaygroundToggle", lazy = true },

  {
    "nvim-treesitter/nvim-treesitter",
    lazy = true,
    event = "BufReadPre",
    opts = {
      ensure_installed = {
        "css",
        "go",
        "graphql",
        "php",
        "scss",
        "sql",
        "javascript",
        "typescript",
        "tsx",
        "lua",
        "query",
        "vim",
        "vimdoc",
      },

      query_linter = {
        enable = true,
        use_virtual_text = true,
        lint_events = { "BufWrite", "CursorHold" },
      },

      playground = {
        enable = true,
        disable = {},
        updatetime = 25,
        persist_queries = true,
        keybindings = {
          toggle_query_editor = "o",
          toggle_hl_groups = "i",
          toggle_injected_languages = "t",
          toggle_anonymous_nodes = "a",
          toggle_language_display = "I",
          focus_language = "f",
          unfocus_language = "F",
          update = "R",
          goto_node = "<cr>",
          show_help = "?",
        },
      },

      -- keymap
      incremental_selection = {
        enable = true,
        keymaps = {
          node_decremental = "<nop>",
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)

      -- MDX
      vim.filetype.add({
        extension = {
          mdx = "mdx",
        },
      })
      vim.treesitter.language.register("markdown", "mdx")

      vim.cmd([[
        highlight clear CursorLine
        highlight clear CursorLineNr
        highlight clear TreesitterContext
      ]])
    end,
  },
}
