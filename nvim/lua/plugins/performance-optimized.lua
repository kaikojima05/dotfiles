-- パフォーマンス最適化設定
return {
  -- 起動時間最適化
  {
    "lewis6991/impatient.nvim", 
    enabled = function()
      return vim.fn.has('nvim-0.9') == 0 -- Neovim 0.9未満でのみ有効
    end,
    config = function()
      local ok, impatient = pcall(require, "impatient")
      if ok then
        impatient.enable_profile()
      end
    end,
  },

  -- ファイルタイプ検出の最適化
  {
    "nathom/filetype.nvim",
    event = { "BufRead", "BufNewFile" },
    config = function()
      require("filetype").setup({
        overrides = {
          extensions = {
            sql = "sql",
            db = "sql",
            mysql = "sql",
            pgsql = "sql",
          },
          literal = {
            [".gitignore"] = "gitignore",
          },
          complex = {
            [".*git/config"] = "gitconfig",
            [".*%.env%..*"] = "sh",
          },
        },
      })
    end,
  },

  -- 大きなファイルの処理最適化
  {
    "LunarVim/bigfile.nvim",
    event = { "FileReadPre", "BufReadPre", "User FileOpened" },
    config = function()
      require("bigfile").setup({
        filesize = 2, -- サイズ制限: 2MB
        pattern = { "*" },
        features = {
          "indent_blankline",
          "illuminate",
          "lsp",
          "treesitter",
          "syntax",
          "matchparen",
          "vimopts",
          "filetype",
        },
      })
    end,
  },

  -- Telescope のパフォーマンス最適化
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      local telescope_ok, telescope = pcall(require, "telescope")
      if telescope_ok then
        telescope.load_extension("fzf")
      end
    end,
  },

  -- LSP パフォーマンス最適化
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    config = function()
      require("fidget").setup({
        progress = {
          poll_rate = 200, -- ポーリング間隔を調整
          suppress_on_insert = true,
        },
        notification = {
          window = {
            winblend = 0,
            border = "none",
            zindex = 45,
          },
        },
      })
    end,
  },

  -- メモリ使用量最適化
  {
    "echasnovski/mini.bufremove",
    version = "*",
    keys = {
      { "<leader>bd", function() require("mini.bufremove").delete() end, desc = "バッファ削除" },
      { "<leader>bD", function() require("mini.bufremove").delete(0, true) end, desc = "強制バッファ削除" },
    },
    config = function()
      require("mini.bufremove").setup()
    end,
  },

  -- キャッシュ最適化
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if opts then
        opts.auto_install = false -- 自動インストール無効化
        opts.sync_install = false -- 同期インストール無効化
        opts.ensure_installed = opts.ensure_installed or {}
        
        -- 基本的な言語のみ保持
        opts.ensure_installed = {
          "lua",
          "vim",
          "vimdoc",
          "query",
          "sql",
          "json",
          "markdown",
        }
        
        -- パフォーマンス設定
        opts.highlight = opts.highlight or {}
        opts.highlight.additional_vim_regex_highlighting = false
        opts.highlight.disable = function(lang, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end
      end
      return opts
    end,
  },

  -- プロジェクト固有の最適化
  {
    "ahmedkhalf/project.nvim",
    opts = function(_, opts)
      if opts then
        -- キャッシュとパフォーマンス設定
        opts.manual_mode = false
        opts.sync_root_with_cwd = true
        opts.respect_buf_cwd = true
        opts.update_focused_file = {
          enable = true,
          update_root = true
        }
        
        -- パフォーマンス向上のための制限
        opts.patterns = {
          ".git",
          "package.json",
          "Cargo.toml", 
          "go.mod",
          "pyproject.toml"
        }
        
        -- 除外パターンの最適化
        opts.exclude_dirs = {
          "*/node_modules/*",
          "*/.git/*",
          "*/target/*",
          "*/build/*",
          "*/dist/*",
          "*/.venv/*",
          "*/venv/*",
        }
      end
      return opts
    end,
  },

  -- データベース接続の最適化
  {
    "tpope/vim-dadbod",
    config = function()
      -- 接続プールの設定
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_force_echo_notifications = 0 -- 通知を抑制
      vim.g.db_ui_disable_mappings_dbout = 0
      
      -- パフォーマンス設定
      vim.g.db_ui_table_helpers = {
        mysql = {
          List = "SELECT * FROM {table} LIMIT 200;",
          Indexes = "SHOW INDEX FROM {table};",
        },
        postgresql = {
          List = "SELECT * FROM {table} LIMIT 200;",
          Indexes = "SELECT * FROM pg_indexes WHERE tablename = '{table}';",
        },
        sqlite = {
          List = "SELECT * FROM {table} LIMIT 200;",
          Indexes = "PRAGMA index_list({table});",
        },
      }
    end,
  },

  -- UI最適化
  {
    "rcarriga/nvim-notify",
    opts = function(_, opts)
      if opts then
        opts.fps = 60 -- フレームレート最適化
        opts.max_width = 80
        opts.max_height = 20
        opts.timeout = 3000 -- 表示時間短縮
        opts.stages = "fade" -- アニメーション簡素化
        opts.render = "minimal" -- レンダリング最適化
      end
      return opts
    end,
  },

  -- 自動コマンドの最適化
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      -- パフォーマンス向上のための自動コマンド
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("PerformanceOptimizations", { clear = true }),
        callback = function()
          -- 大きなファイルでのパフォーマンス調整
          local buf = vim.api.nvim_get_current_buf()
          local line_count = vim.api.nvim_buf_line_count(buf)
          
          if line_count > 5000 then
            vim.bo[buf].syntax = "off"
            vim.bo[buf].filetype = ""
          end
        end,
      })
      
      -- メモリクリーンアップ
      vim.api.nvim_create_autocmd("FocusLost", {
        group = vim.api.nvim_create_augroup("MemoryCleanup", { clear = true }),
        callback = function()
          if vim.fn.mode() == "n" then
            pcall(vim.cmd, "silent! wall") -- 全ファイル保存
            collectgarbage("collect") -- ガベージコレクション実行
          end
        end,
      })
      
      return opts
    end,
  },
}