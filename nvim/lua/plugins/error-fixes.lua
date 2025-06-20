-- エラー修正とフォールバック設定
return {
  -- Neo-tree設定の安定化（既存のneo-tree設定との競合回避）
  -- {
  --   "nvim-neo-tree/neo-tree.nvim",
  --   enabled = false, -- project-management.luaと競合するため無効化
  -- },

  -- Windows.nvimの条件付き読み込み
  {
    "anuvyklack/windows.nvim",
    enabled = false, -- 安定性のため一時無効化
  },

  -- SQLプラグインの簡素化
  {
    "jsborjesson/vim-uppercase-sql",
    enabled = false, -- 安定性のため無効化
  },

  {
    "nanotee/sqls.nvim",
    enabled = false, -- 安定性のため無効化
  },

  {
    "dinhhuy258/vim-database", 
    enabled = false, -- 安定性のため無効化
  },

  -- Alpha.nvimの安全な設定
  {
    "goolord/alpha-nvim",
    enabled = false, -- 既存設定との競合回避
  },

  -- Lualineの重複回避
  {
    "nvim-lualine/lualine.nvim",
    enabled = function()
      -- LazyVimが既にlualineを管理している場合は無効化
      return not vim.g.loaded_lualine
    end,
  },

  -- Bufferlineの重複回避
  {
    "akinsho/bufferline.nvim",
    enabled = function()
      -- LazyVimが既にbufferlineを管理している場合は無効化
      return not vim.g.loaded_bufferline
    end,
  },

  -- Telescopeの設定重複回避
  {
    "nvim-telescope/telescope.nvim",
    enabled = function()
      -- 既存のTelescope設定との競合を回避
      local has_telescope = pcall(require, "telescope")
      return not has_telescope
    end,
  },

  -- CMP設定の重複回避
  {
    "hrsh7th/nvim-cmp",
    enabled = function()
      -- LazyVimが既にcmpを管理している場合は無効化
      return not vim.g.loaded_cmp
    end,
  },

  -- 安全な基本設定のみ適用
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      -- プロジェクト管理の基本設定のみ
      opts = opts or {}
      
      -- 安全なキーマッピングのみ追加
      vim.keymap.set('n', '<leader>pf', function()
        local telescope_ok = pcall(vim.cmd, 'Telescope find_files')
        if not telescope_ok then
          vim.cmd('edit .')
        end
      end, { desc = "ファイル検索" })
      
      vim.keymap.set('n', '<leader>pg', function()
        local telescope_ok = pcall(vim.cmd, 'Telescope live_grep')
        if not telescope_ok then
          vim.notify("Grep not available", vim.log.levels.WARN)
        end
      end, { desc = "プロジェクト内検索" })
      
      -- データベース関連の安全なキーマッピング
      vim.keymap.set('n', '<leader>du', function()
        local db_ok = pcall(vim.cmd, 'DBUIToggle')
        if not db_ok then
          vim.notify("DBUI not available", vim.log.levels.WARN)
        end
      end, { desc = "DB UI切り替え" })
      
      return opts
    end,
  },

  -- プロジェクト管理用のディレクトリ作成
  {
    "folke/lazy.nvim",
    config = function()
      -- 必要なディレクトリを作成
      local data_path = vim.fn.stdpath("data")
      local dirs = {
        data_path .. "/dadbod_ui",
        data_path .. "/dadbod_ui/tmp",
        data_path .. "/sessions",
      }
      
      for _, dir in ipairs(dirs) do
        if vim.fn.isdirectory(dir) == 0 then
          vim.fn.mkdir(dir, "p")
        end
      end
    end,
  },
}