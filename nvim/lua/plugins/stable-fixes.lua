-- 安定性修正とプラグインの補完（最適化済み）
return {
  -- 必要な依存関係を確実に追加（パフォーマンス最適化）
  {
    "nvim-lua/plenary.nvim",
    lazy = false,
    priority = 1000,
  },

  -- Telescope統合の安定化
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { 
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons"
    },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "ファイル検索" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "プロジェクト内検索" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "バッファ一覧" },
    },
    config = function()
      local telescope_ok, telescope = pcall(require, 'telescope')
      if not telescope_ok then
        vim.notify("Telescope could not be loaded", vim.log.levels.ERROR)
        return
      end
      
      telescope.setup({
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { "truncate" },
          file_ignore_patterns = {
            "node_modules/.*",
            "%.git/.*",
            "target/.*",
            "build/.*",
            "dist/.*",
          },
        },
        pickers = {
          find_files = {
            theme = "dropdown",
            hidden = true,
          },
          live_grep = {
            theme = "dropdown",
          },
          buffers = {
            theme = "dropdown",
            previewer = false,
          },
        },
      })
    end,
  },

  -- アイコンサポートの安定化
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      local icons_ok, devicons = pcall(require, "nvim-web-devicons")
      if not icons_ok then
        return
      end
      
      devicons.setup({
        override = {
          sql = {
            icon = "🗄️",
            color = "#336791",
            cterm_color = "65",
            name = "Sql"
          },
        },
        default = true,
      })
    end,
  },

  -- 通知システムの安定化
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      local notify_ok, notify = pcall(require, "notify")
      if not notify_ok then
        return
      end
      
      notify.setup({
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
        timeout = 5000,
        top_down = true
      })
      
      -- デフォルト通知をnvim-notifyに設定
      vim.notify = notify
    end,
  },

  -- UIライブラリの安定化
  {
    "MunifTanjim/nui.nvim",
    lazy = true,
  },

  -- プロジェクト固有設定の安定化
  {
    "folke/neoconf.nvim",
    event = "VeryLazy",
    config = function()
      local neoconf_ok, neoconf = pcall(require, "neoconf")
      if not neoconf_ok then
        return
      end
      
      neoconf.setup({
        import = {
          vscode = true,
          coc = false,
          nlsp = false,
        },
        live_reload = true,
        filetype_jsonc = true,
      })
    end,
  },

  -- セッション管理の安定化
  {
    "rmagatti/auto-session",
    event = "VeryLazy",
    config = function()
      local session_ok, auto_session = pcall(require, "auto-session")
      if not session_ok then
        vim.notify("auto-session could not be loaded", vim.log.levels.WARN)
        return
      end
      
      auto_session.setup({
        log_level = "error",
        auto_session_suppress_dirs = { "~/", "~/Downloads", "/" },
        auto_session_use_git_branch = false, -- 安定性のため無効化
        auto_session_enable_last_session = false, -- 安定性のため無効化
        auto_save_enabled = true,
        auto_restore_enabled = false, -- 手動制御
        auto_session_root_dir = vim.fn.stdpath('data').."/sessions/",
      })
      
      -- 手動セッション管理のキーマッピング
      vim.keymap.set('n', '<leader>ss', function()
        pcall(function() vim.cmd('SessionSave') end)
      end, { desc = "セッション保存" })
      
      vim.keymap.set('n', '<leader>sr', function()
        pcall(function() vim.cmd('SessionRestore') end)
      end, { desc = "セッション復元" })
    end,
  },

  -- エラーハンドリング強化
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk_ok, wk = pcall(require, "which-key")
      if not wk_ok then
        return
      end
      
      wk.setup({
        plugins = {
          marks = false,
          registers = false,
          spelling = {
            enabled = false,
          },
        },
        window = {
          border = "rounded",
          position = "bottom",
          margin = { 1, 0, 1, 0 },
          padding = { 2, 2, 2, 2 },
        },
        layout = {
          height = { min = 4, max = 25 },
          width = { min = 20, max = 50 },
          spacing = 3,
          align = "left",
        },
        ignore_missing = true,
        hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " },
      })
    end,
  },

  -- LSP補完の安定化
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
    },
    config = function()
      local cmp_ok, cmp = pcall(require, "cmp")
      if not cmp_ok then
        return
      end
      
      cmp.setup({
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        window = {
          completion = {
            border = "rounded",
            scrollbar = true,
          },
          documentation = {
            border = "rounded",
          },
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'path' },
        }),
      })
    end,
  },

  -- 自動ペア補完の安定化
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local autopairs_ok, autopairs = pcall(require, "nvim-autopairs")
      if not autopairs_ok then
        return
      end
      
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
          offset = 0,
          end_key = '$',
          keys = 'qwertyuiopzxcvbnmasdfghjkl',
          check_comma = true,
          highlight = 'PmenuSel',
          highlight_grey='LineNr'
        },
      })
      
      -- nvim-cmpとの統合
      local cmp_autopairs_ok, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
      local cmp_ok, cmp = pcall(require, "cmp")
      if cmp_autopairs_ok and cmp_ok then
        cmp.event:on(
          'confirm_done',
          cmp_autopairs.on_confirm_done()
        )
      end
    end,
  }
}