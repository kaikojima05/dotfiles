-- エラーフリー環境の包括的実現
return {
  -- Mason関連プラグインの競合回避と最適化
  {
    "williamboman/mason.nvim",
    enabled = function()
      -- project-detector.luaでMasonを管理するため、重複を避ける
      return false
    end,
  },
  
  -- LSP設定の競合回避
  {
    "neovim/nvim-lspconfig",
    enabled = function()
      -- project-detector.luaでLSP設定を管理するため、重複を避ける
      return false
    end,
  },
  
  -- Treesitterの安定化（エラーフリー設定）
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts = opts or {}
      
      -- 基本言語のみインストール（エラー回避）
      opts.ensure_installed = {
        "lua",
        "vim",
        "vimdoc",
        "query",
        "markdown",
        "markdown_inline",
      }
      
      -- 自動インストール無効化（エラー回避）
      opts.auto_install = false
      opts.sync_install = false
      
      -- パフォーマンス設定
      opts.highlight = opts.highlight or {}
      opts.highlight.enable = true
      opts.highlight.additional_vim_regex_highlighting = false
      
      -- 大きなファイルでのエラー回避
      opts.highlight.disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end
      
      -- インデント設定（エラー回避）
      opts.indent = opts.indent or {}
      opts.indent.enable = true
      
      return opts
    end,
  },
  
  -- CMP設定の安定化
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer", 
      "hrsh7th/cmp-path",
    },
    opts = function(_, opts)
      local cmp = require("cmp")
      
      opts = opts or {}
      
      -- 安全な補完設定
      opts.completion = {
        completeopt = "menu,menuone,noinsert",
      }
      
      -- ソース設定（エラーフリー）
      opts.sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 1000 },
        { name = "buffer", priority = 500 },
        { name = "path", priority = 250 },
      })
      
      -- フォーマット設定（安全）
      opts.formatting = {
        format = function(entry, vim_item)
          -- アイコン設定（安全）
          local icons = {
            Text = "📝", Method = "🔧", Function = "⚡", Constructor = "🏗️",
            Field = "🏷️", Variable = "📦", Class = "🏛️", Interface = "🔌",
            Module = "📚", Property = "🎛️", Unit = "📐", Value = "💎",
            Enum = "📋", Keyword = "🔑", Snippet = "✂️", Color = "🎨",
            File = "📄", Reference = "📎", Folder = "📁", EnumMember = "🏷️",
            Constant = "💯", Struct = "🏗️", Event = "⚡", Operator = "➕",
            TypeParameter = "🎯",
          }
          
          vim_item.kind = string.format("%s %s", icons[vim_item.kind] or "", vim_item.kind)
          
          -- ソース名表示
          vim_item.menu = ({
            nvim_lsp = "[LSP]",
            buffer = "[Buffer]",
            path = "[Path]",
          })[entry.source.name]
          
          return vim_item
        end,
      }
      
      -- ウィンドウ設定（安全）
      opts.window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      }
      
      -- キーマッピング（エラーフリー）
      opts.mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end, { "i", "s" }),
      })
      
      return opts
    end,
  },
  
  -- Telescope設定の安定化
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      opts = opts or {}
      
      -- デフォルト設定（エラーフリー）
      opts.defaults = opts.defaults or {}
      opts.defaults.prompt_prefix = " "
      opts.defaults.selection_caret = " "
      opts.defaults.path_display = { "truncate" }
      opts.defaults.sorting_strategy = "ascending"
      opts.defaults.layout_strategy = "horizontal"
      
      -- レイアウト設定
      opts.defaults.layout_config = {
        horizontal = {
          prompt_position = "top",
          preview_width = 0.55,
          results_width = 0.8,
        },
        vertical = {
          mirror = false,
        },
        width = 0.87,
        height = 0.80,
        preview_cutoff = 120,
      }
      
      -- ファイル無視設定（パフォーマンス向上）
      opts.defaults.file_ignore_patterns = {
        "node_modules/.*",
        "%.git/.*",
        "target/.*",
        "build/.*", 
        "dist/.*",
        "%.class$",
        "%.jar$",
      }
      
      -- ピッカー設定
      opts.pickers = opts.pickers or {}
      opts.pickers.find_files = {
        theme = "dropdown",
        previewer = false,
        hidden = true,
      }
      opts.pickers.live_grep = {
        theme = "dropdown",
      }
      opts.pickers.buffers = {
        theme = "dropdown",
        previewer = false,
      }
      
      return opts
    end,
  },
  
  -- 通知システムの安定化
  {
    "rcarriga/nvim-notify",
    opts = {
      background_colour = "#000000",
      fps = 30,
      icons = {
        DEBUG = "🐛",
        ERROR = "❌", 
        INFO = "ℹ️",
        TRACE = "🔍",
        WARN = "⚠️"
      },
      level = 2,
      minimum_width = 50,
      render = "default",
      stages = "fade_in_slide_out",
      timeout = 3000,
      top_down = true
    },
    config = function(_, opts)
      local notify = require("notify")
      notify.setup(opts)
      
      -- デフォルト通知をnvim-notifyに設定
      vim.notify = notify
      
      -- エラー通知の抑制（開発時の不要な通知を減らす）
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = function()
          -- 特定のエラーメッセージを抑制
          local original_notify = vim.notify
          vim.notify = function(msg, level, opts)
            -- Mason関連の警告を抑制
            if type(msg) == "string" and (
              msg:match("mason%.nvim") or
              msg:match("packages are still installing") or
              msg:match("Installation was aborted")
            ) then
              return
            end
            
            return original_notify(msg, level, opts)
          end
        end,
      })
    end,
  },
  
  -- LazyVim設定の最適化
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      opts = opts or {}
      
      -- デフォルト設定の安定化
      opts.defaults = opts.defaults or {}
      opts.defaults.lazy = true -- 遅延読み込み有効
      opts.defaults.version = false -- git HEADを使用
      
      -- パフォーマンス設定
      opts.performance = opts.performance or {}
      opts.performance.cache = { enabled = true }
      opts.performance.reset_packpath = true
      opts.performance.rtp = {
        reset = true,
        paths = {},
        disabled_plugins = {
          "gzip",
          "matchit",
          "matchparen", 
          "netrwPlugin",
          "tarPlugin",
          "tohtml",
          "tutor",
          "zipPlugin",
        },
      }
      
      -- UI設定
      opts.ui = opts.ui or {}
      opts.ui.border = "rounded"
      opts.ui.backdrop = 100
      
      return opts
    end,
  },
  
  -- エラーハンドリング強化
  {
    "folke/neoconf.nvim",
    priority = 1000,
    config = function()
      require("neoconf").setup({
        -- プロジェクト固有設定の安全な読み込み
        import = {
          vscode = true,
          coc = false, -- 競合回避
          nlsp = false, -- 競合回避
        },
        live_reload = true,
        filetype_jsonc = true,
        plugins = {
          lspconfig = {
            enabled = true,
          },
          jsonls = {
            enabled = true,
            configured_servers_only = true,
          },
        },
      })
    end,
  },
  
  -- 自動ペア補完の安定化
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local autopairs = require("nvim-autopairs")
      
      autopairs.setup({
        check_ts = true,
        ts_config = {
          lua = {'string', 'source'},
          javascript = {'string', 'template_string'},
        },
        disable_filetype = { "TelescopePrompt", "vim" },
        fast_wrap = {
          map = '<M-e>',
          chars = { '{', '[', '(', '"', "'" },
          pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], '%s+', ''),
          end_key = '$',
          keys = 'qwertyuiopzxcvbnmasdfghjkl',
          check_comma = true,
          highlight = 'Search',
          highlight_grey='Comment'
        },
      })
      
      -- nvim-cmpとの統合（エラーフリー）
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      local cmp = require('cmp')
      cmp.event:on(
        'confirm_done',
        cmp_autopairs.on_confirm_done()
      )
    end,
  },
  
  -- プロジェクト検出統合の確認
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts = opts or {}
      
      -- プロジェクト検出コマンドの登録
      require("which-key").register({
        ["<leader>P"] = {
          name = "🔍 Project Detection",
          d = { "<cmd>ProjectDetect<cr>", "プロジェクト型検出" },
          t = { "<cmd>ProjectTools<cr>", "必要ツール表示" },
          i = { function()
            local project_detector = require("plugins.project-detector")
            project_detector.show_project_info()
          end, "プロジェクト情報表示" },
        },
      })
      
      return opts
    end,
  },
}