return {
  {
    enabled = false,
    "folke/flash.nvim",
    ---@type Flash.Config
    opts = {
      search = {
        forward = true,
        multi_window = false,
        wrap = false,
        incremental = true,
      },
    },
  },


  {
    "dinhhuy258/git.nvim",
    event = "BufReadPre",
    opts = {
      keymaps = {
        -- Open blame window
        blame = "<Leader>gb",
        -- Open file/folder in git repository
        browse = "<Leader>go",
      },
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      "nvim-telescope/telescope-file-browser.nvim",
    },
    keys = {
      {
        "<leader>f",
        function()
          local builtin = require("telescope.builtin")
          builtin.find_files({
            no_ignore = false,
            hidden = true,
          })
        end,
        desc = "Lists files in your current working directory, respects .gitignore",
      },
      {
        "g/",
        function()
          local builtin = require("telescope.builtin")
          builtin.live_grep({
            additional_args = { "--hidden", "--fixed-strings" },
          })
        end,
        desc = "Search for a string in your current working directory and get results live as you type, respects .gitignore",
      },
      {
        "g.",
        function()
          require("telescope.builtin").lsp_document_symbols()
        end,
        desc = "Search symbols in current buffer",
      },
      {
        "<leader>bl",
        function()
          local builtin = require("telescope.builtin")
          local actions = require("telescope.actions")
          builtin.buffers({
            attach_mappings = function(_, map)
              map('n', 'd', actions.delete_buffer)
              return true
            end
          })
        end,
        desc = "Lists open buffers",
      },
      -- LazyVim デフォルトを無効化
      { "<leader>d", false },
      {
        "sf",
        function()
          local telescope = require("telescope")

          local function telescope_buffer_dir()
            return vim.fn.expand("%:p:h")
          end

          telescope.extensions.file_browser.file_browser({
            path = "%:p:h",
            cwd = telescope_buffer_dir(),
            respect_gitignore = false,
            hidden = true,
            grouped = true,
            previewer = false,
            initial_mode = "normal",
            layout_config = { height = 40 },
          })
        end,
        desc = "Open File Browser with the path of the current buffer",
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local fb_actions = require("telescope").extensions.file_browser.actions

      opts.defaults = vim.tbl_deep_extend("force", opts.defaults, {
        -- 隠しファイルも表示する設定				wrap_results = true,
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
        mappings = {
          n = {},
        },
      })
      opts.pickers = {
        diagnostics = {
          theme = "ivy",
          initial_mode = "normal",
          layout_config = {
            preview_cutoff = 9999,
          },
        },
      }
      opts.extensions = {
        file_browser = {
          hidden = true, -- 隠しファイルを表示
          theme = "dropdown",
          -- disables netrw and use telescope-file-browser in its place
          hijack_netrw = false,
          display_stat = false, -- アイコン表示を snacks.nvim explorer と統一
          mappings = {
            -- your custom insert mode mappings
            ["n"] = {
              -- your custom normal mode mappings
              ["a"] = fb_actions.create,
              ["r"] = fb_actions.rename,
              ["d"] = fb_actions.remove,
              ["m"] = fb_actions.move,
              ["c"] = fb_actions.copy,
              ["h"] = fb_actions.goto_parent_dir,
              ["l"] = actions.select_default,
              ["/"] = function()
                vim.cmd("startinsert")
              end,
              ["<PageUp>"] = actions.preview_scrolling_up,
              ["<PageDown>"] = actions.preview_scrolling_down,
            },
          },
        },
      }
      telescope.setup(opts)
      require("telescope").load_extension("fzf")
      require("telescope").load_extension("file_browser")
    end,
  },

  {
    "kazhala/close-buffers.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>th",
        function()
          require("close_buffers").delete({ type = "hidden" })
        end,
        "Close Hidden Buffers",
      },
      {
        "<leader>tu",
        function()
          require("close_buffers").delete({ type = "nameless" })
        end,
        "Close Nameless Buffers",
      },
    },
  },

  { "saghen/blink.cmp", enabled = false },

  -- Bigfile handling
  {
    "LunarVim/bigfile.nvim",
    event = "BufReadPre",
    opts = {
      filesize = 2, -- size of the file in MiB
    },
  },

  -- Enhanced filetype detection (disabled - using built-in Neovim filetype detection)
  {
    "nathom/filetype.nvim",
    enabled = false,
    config = function()
      require("filetype").setup({
        overrides = {
          extensions = {
            tf = "terraform",
            tfvars = "terraform",
            tfstate = "json",
          },
        },
      })
    end,
  },

  -- Todo comments with enhanced navigation
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = { "BufReadPost", "BufNewFile" },
    config = true,
    keys = {
      -- LazyVim デフォルトを無効化
      {
        "<leader>tl",
        "<cmd>TodoTrouble<cr>",
        desc = "Todo (Trouble)",
      },
    },
  },

  -- Trouble diagnostics with keymaps
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      -- LazyVim デフォルトの symbols キーを無効化（g. で Telescope を使用）
      {
        "<leader>d",
        "<cmd>Trouble diagnostics focus<cr>",
        desc = "Focus Trouble diagnostics window",
      },
    },
  },

  -- vim-visual-multi (VSCode-like multi-cursor)
  {
    "mg979/vim-visual-multi",
    branch = "master",
    event = "VeryLazy",
    init = function()
      -- VSCode-like keymaps
      vim.g.VM_maps = {
        ["Find Under"] = "<D-d>", -- cmd+d: select word under cursor
        ["Find Subword Under"] = "<D-d>", -- cmd+d: select subword
        ["Add Cursor Down"] = "", -- disabled (use Ctrl-v + j/k instead)
        ["Add Cursor Up"] = "", -- disabled (use Ctrl-v + j/k instead)
        ["Select All"] = "", -- disable default
        ["Start Regex Search"] = "", -- disable default
        ["Visual Regex"] = "", -- disable default
        ["Visual All"] = "", -- disable default
        ["Visual Cursors"] = "", -- disable default
      }
      vim.g.VM_theme = "iceblue"
      -- Don't show warnings
      vim.g.VM_silent_exit = 1
      vim.g.VM_show_warnings = 0
    end,
  },

  -- Project management
  {
    "ahmedkhalf/project.nvim",
    opts = {
      detection_methods = { "lsp", "pattern" },
      patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
    },
    event = "VeryLazy",
    config = function(_, opts)
      require("project_nvim").setup(opts)
      require("telescope").load_extension("projects")
    end,
    keys = {
      {
        "<leader>fp",
        "<cmd>Telescope projects<cr>",
        desc = "Projects",
      },
    },
  },
}
