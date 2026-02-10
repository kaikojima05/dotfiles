return {
  -- messages, cmdline and the popupmenu
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      table.insert(opts.routes, {
        filter = {
          event = "notify",
          find = "No information available",
        },
        opts = { skip = true },
      })

      -- tailwindcss が callHierarchy をサポートしないエラーを無視
      table.insert(opts.routes, {
        filter = {
          event = "notify",
          find = "Unhandled method callHierarchy",
        },
        opts = { skip = true },
      })

      -- lazy.nvim 通知: 表示するが履歴には残さない
      table.insert(opts.routes, {
        filter = {
          event = "notify",
          find = "lazy.nvim",
        },
        opts = { history = false },
      })

      local focused = true

      vim.api.nvim_create_autocmd("FocusGained", {
        callback = function()
          focused = true
        end,
      })

      vim.api.nvim_create_autocmd("FocusLost", {
        callback = function()
          focused = false
        end,
      })

      table.insert(opts.routes, 1, {
        filter = {
          cond = function()
            return not focused
          end,
        },
        view = "notify_send",
        opts = { stop = false },
      })

      opts.commands = {
        all = {
          -- options for the message history that you get with `:Noice`
          view = "split",
          opts = { enter = true, format = "details" },
          filter = {},
        },
      }

      opts.notify = {
        -- notify のデフォルト設定
        enabled = true,
        view = "notify",
      }

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function(event)
          vim.schedule(function()
            require("noice.text.markdown").keys(event.buf)
          end)
        end,
      })

      -- presets を初期化してから設定
      opts.presets = opts.presets or {}
      opts.presets.lsp_doc_border = true

      -- LSP を Noice でオーバーライド
      opts.lsp = opts.lsp or {}
      opts.lsp.override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = false, -- ネイティブ hover を使うため無効化
        ["cmp.entry.get_documentation"] = true,
      }
      opts.lsp.hover = {
        enabled = false, -- ネイティブ LSP handler を使用
      }
      opts.lsp.signature = {
        enabled = true,
      }

      -- views をマージ（上書きしない）
      opts.views = opts.views or {}
      opts.views.notify = {
        backend = "notify",
        opts = {
          stages = "slide",
          fps = 60,
        },
      }
    end,
    dependencies = {
      "rcarriga/nvim-notify",
    },
  },

  {
    "rcarriga/nvim-notify",
    opts = {
      timeout = 3500,
      stages = "slide",
      top_down = true,
      render = "default",
      fps = 60,
      level = vim.log.levels.WARN,
    },
  },

  {
    "snacks.nvim",
    opts = {
      indent = { enabled = false },
      input = { enabled = true },
      notifier = { enabled = true },
      picker = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = false },
      statuscolumn = { enabled = false },
      toggle = { map = vim.keymap.set },
      words = { enabled = true },
      explorer = {
        hidden = true,
        show_hidden = true,
      },
    },
    keys = {
      {
        "<leader>sn",
        function()
          local snacks = require("snacks")
          ---@diagnostic disable-next-line: undefined-field
          if snacks.config.picker and snacks.config.picker.enabled then
            snacks.picker.notifications()
          else
            snacks.notifier.show_history()
          end
        end,
        desc = "Notification History",
      },
      {
        "<leader>un",
        function()
          require("snacks").notifier.hide()
        end,
        desc = "Dismiss All Notifications",
      },
    },
  },

  {
    "snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = [[
          ███╗    ██╗████████╗ ███████╗ ██╗   ██╗██╗███╗   ███╗          Z
          ████╗   ██║██╔═════╝███╔══███╗██║   ██║██║████╗ ████║      Z    
          ██╔═███╔██║█████╗   ██╔╝  ║██║██║   ██║██║██╔████╔██║   z       
          ██║  ╚████║██╔══╝   ███╗  ███║╚██╗ ██╔╝██║██║╚██╔╝██║ z         
          ██║   ╚███║████████╗╚███████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║           
          ╚═╝     ╚═╝╚═══════╝ ╚══════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝           
   ]],
        },
      },
    },
  },

  -- mini.indentscope for showing current scope only
  {
    "nvim-mini/mini.indentscope",
    version = false,
    event = "LazyFile",
    opts = {
      symbol = "│",
      options = {
        try_as_border = true,
        border = "both",
      },
      draw = {
        delay = 0,
        animation = function()
          return 0
        end,
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },

  -- gitsigns for showing git diff indicators
  {
    "lewis6991/gitsigns.nvim",
    event = "LazyFile",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      signs_staged = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
      numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
      linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
      word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
      current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
      attach_to_untracked = true,
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "<leader>n", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next", { preview = true })
          end
        end, { desc = "Next Hunk & Preview" })

        map("n", "<leader>p", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev", { preview = true })
          end
        end, { desc = "Prev Hunk & Preview" })

        map("n", "<leader>gh", gs.preview_hunk, { desc = "Preview Hunk" })
      end,
    },
  },

  -- statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "SmiteshP/nvim-navic" },
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.section_separators = { left = " " }
      opts.options.component_separators = { left = " " }

      ---@diagnostic disable-next-line: no-unknown
      opts.sections.lualine_c[1] = ""
      ---@diagnostic disable-next-line: no-unknown
      opts.sections.lualine_c[4] = { "navic", color_correction = "static" }
      ---@diagnostic disable-next-line: no-unknown
      opts.sections.lualine_c[5] = {}
      ---@diagnostic disable-next-line: no-unknown
      opts.sections.lualine_x = {}
      ---@diagnostic disable-next-line: no-unknown
      opts.sections.lualine_y = {}
      ---@diagnostic disable-next-line: no-unknown
      opts.sections.lualine_z = {}

      -- 上部に tabline としてバッファリストを表示
      opts.tabline = {
        lualine_a = {
          {
            "buffers",
            show_filename_only = true,
            hide_filename_extension = false,
            show_modified_status = true,
            mode = 0,
            max_length = vim.o.columns * 2 / 3,
            symbols = {
              modified = "  ",
              alternate_file = "",
              directory = "",
            },
            left_padding = 2,
            buffers_color = {
              active = { fg = "#ffffff", gui = "bold" },
              inactive = { bg = "#0d1117", fg = "#888888" },
            },
            sections = { "error" },
          },
        },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      }
    end,
  },

  -- zen-mode を無効化
  { "folke/zen-mode.nvim", enabled = false },

  -- Enhanced which-key configuration (v3 compatible)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = { spelling = true },
    },
  },
}
