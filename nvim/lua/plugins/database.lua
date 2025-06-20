return {
  -- データベース接続・操作の核心プラグイン
  {
    "tpope/vim-dadbod",
    event = "VeryLazy",
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",
      "kristijanhusak/vim-dadbod-completion",
    },
    config = function()
      -- 安全な初期化チェック
      if not pcall(require, "vim-dadbod") then
        vim.notify("vim-dadbod could not be loaded", vim.log.levels.WARN)
        -- エラーでも継続して設定を適用
      end
      -- データベース接続設定
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/dadbod_ui"
      vim.g.db_ui_tmp_query_location = vim.fn.stdpath("data") .. "/dadbod_ui/tmp"
      
      -- UI設定（IntelliJ IDEA風）
      vim.g.db_ui_winwidth = 40
      vim.g.db_ui_auto_execute_table_helpers = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_force_echo_notifications = 1
      vim.g.db_ui_win_position = 'left'
      vim.g.db_ui_use_nerd_fonts = 1
      
      -- 実行結果の表示設定
      vim.g.db_ui_execute_on_save = 0
      vim.g.db_ui_disable_mappings = 0
      
      -- アイコン設定
      vim.g.db_ui_icons = {
        expanded = {
          db = '▾ ',
          buffers = '▾ ',
          saved_queries = '▾ ',
          schemas = '▾ ',
          schema = '▾ פּ',
          tables = '▾ 藺',
          table = '▾ ',
        },
        collapsed = {
          db = '▸ ',
          buffers = '▸ ',
          saved_queries = '▸ ',
          schemas = '▸ ',
          schema = '▸ פּ',
          tables = '▸ 藺',
          table = '▸ ',
        },
        saved_query = '',
        new_query = '璘',
        tables = '離',
        buffers = '﬘',
        add_connection = '',
        connection_ok = '✓',
        connection_error = '✕',
      }
      
      -- キーマッピング（IntelliJ IDEA風）
      vim.keymap.set('n', '<leader>du', ':DBUIToggle<CR>', { desc = "データベースUI切り替え" })
      vim.keymap.set('n', '<leader>df', ':DBUIFindBuffer<CR>', { desc = "データベースバッファ検索" })
      vim.keymap.set('n', '<leader>dr', ':DBUIRenameBuffer<CR>', { desc = "データベースバッファ名前変更" })
      vim.keymap.set('n', '<leader>dq', ':DBUILastQueryInfo<CR>', { desc = "最後のクエリ情報" })
      
      -- データベース固有のキーマッピング
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          vim.keymap.set('n', '<leader>dr', ':DBUIExecuteQuery<CR>', { desc = "クエリ実行", buffer = true })
          vim.keymap.set('v', '<leader>dr', ':DBUIExecuteQuery<CR>', { desc = "選択クエリ実行", buffer = true })
          vim.keymap.set('n', '<F5>', ':DBUIExecuteQuery<CR>', { desc = "クエリ実行（F5）", buffer = true })
          vim.keymap.set('v', '<F5>', ':DBUIExecuteQuery<CR>', { desc = "選択クエリ実行（F5）", buffer = true })
        end,
      })
    end,
  },

  -- SQL補完強化
  {
    "kristijanhusak/vim-dadbod-completion",
    dependencies = { "tpope/vim-dadbod" },
    ft = { "sql", "mysql", "plsql" },
    config = function()
      -- nvim-cmpとの統合設定
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          local cmp = require('cmp')
          local sources = vim.tbl_extend('force', cmp.get_config().sources, {
            { name = 'vim-dadbod-completion' }
          })
          cmp.setup.buffer({ sources = sources })
        end,
      })
    end,
  },

  -- データベース接続マネージャー
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod" },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    config = function()
      -- 接続設定の完全性確認と安全な自動読み込み
      local db_config_file = vim.fn.stdpath("config") .. "/database_connections.json"
      
      if vim.fn.filereadable(db_config_file) == 1 then
        local ok, content = pcall(vim.fn.readfile, db_config_file)
        if ok and content then
          local decode_ok, config_data = pcall(vim.fn.json_decode, content)
          if decode_ok and type(config_data) == "table" then
            -- 新しい形式の設定ファイルをサポート
            local connections = config_data.connections or config_data
            local safe_count = 0
            local total_count = 0
            
            for name, config in pairs(connections) do
              if type(name) == "string" and not name:match("^_") then -- メタデータ除外
                total_count = total_count + 1
                
                if type(config) == "string" then
                  -- 旧形式との互換性
                  vim.g["db#" .. name] = config
                  safe_count = safe_count + 1
                elseif type(config) == "table" and config.url then
                  -- 新形式のサポート
                  if config.safe ~= false then
                    vim.g["db#" .. name] = config.url
                    safe_count = safe_count + 1
                  else
                    vim.notify(string.format("Connection '%s' marked as unsafe, skipped", name), vim.log.levels.INFO)
                  end
                end
              end
            end
            
            vim.notify(string.format("Loaded %d/%d database connections", safe_count, total_count), vim.log.levels.INFO)
          else
            vim.notify("database_connections.json format error", vim.log.levels.WARN)
          end
        end
      end
      
      -- 結果ビューの設定
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "dbout",
        callback = function()
          vim.opt_local.foldenable = false
          vim.opt_local.wrap = false
          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
          vim.opt_local.signcolumn = "no"
        end,
      })
      
      -- クエリファイルの設定
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "sql",
        callback = function()
          vim.opt_local.commentstring = "-- %s"
          vim.opt_local.tabstop = 2
          vim.opt_local.shiftwidth = 2
          vim.opt_local.expandtab = true
        end,
      })
    end,
  },

  -- データベースレコードの可視化
  {
    "dinhhuy258/vim-database",
    dependencies = { "tpope/vim-dadbod" },
    ft = { "sql", "mysql", "plsql" },
    config = function()
      -- テーブルビューの設定
      vim.g.vim_database_auto_execute_table_helpers = 1
      vim.g.vim_database_show_results_in_quickfix = 0
      
      -- カスタムテーブルフォーマット
      vim.g.vim_database_table_format = {
        mysql = "table",
        postgresql = "table",
        sqlite = "table",
      }
    end,
  },

  -- SQL構文ハイライト強化
  {
    "jsborjesson/vim-uppercase-sql",
    ft = { "sql", "mysql", "plsql" },
    config = function()
      -- SQLキーワードの自動大文字化
      vim.g.uppercase_sql_enabled = 1
      
      -- 自動整形の設定
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          vim.keymap.set('n', '<leader>sf', ':SqlFormat<CR>', { desc = "SQL整形", buffer = true })
          vim.keymap.set('v', '<leader>sf', ':SqlFormat<CR>', { desc = "選択SQL整形", buffer = true })
        end,
      })
    end,
  },

  -- SQLクエリ履歴管理
  {
    "nanotee/sqls.nvim",
    ft = { "sql", "mysql", "plsql" },
    config = function()
      require('sqls').setup({
        picker = 'telescope',
        settings = {
          sqls = {
            connections = {
              {
                driver = 'mysql',
                dataSourceName = 'user:password@tcp(localhost:3306)/database',
              },
              {
                driver = 'postgresql',
                dataSourceName = 'host=localhost port=5432 user=postgres password=password dbname=database sslmode=disable',
              },
              {
                driver = 'sqlite3',
                dataSourceName = './database.db',
              },
            },
          },
        },
      })
      
      -- LSP統合キーマッピング
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "定義へ移動", buffer = true })
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = "参照を表示", buffer = true })
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "ホバー情報", buffer = true })
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = "リネーム", buffer = true })
        end,
      })
    end,
  },

  -- データベース図式化
  {
    "kndndrj/nvim-dbee",
    dependencies = { "MunifTanjim/nui.nvim" },
    cmd = { "Dbee" },
    build = function()
      -- 安全なインストール
      local ok, dbee = pcall(require, "dbee")
      if ok then
        pcall(dbee.install)
      end
    end,
    config = function()
      local ok, dbee = pcall(require, "dbee")
      if not ok then
        vim.notify("nvim-dbee could not be loaded", vim.log.levels.WARN)
        return
      end
      
      dbee.setup({
        sources = {
          require("dbee.sources").EnvSource:new("DBEE_CONNECTIONS"),
          require("dbee.sources").FileSource:new(vim.fn.stdpath("config") .. "/dbee/connections.json"),
        },
        drawer = {
          disable_help = false,
          disable_candies = false,
        },
        editor = {
          directory = vim.fn.stdpath("state") .. "/dbee/editor",
        },
        result = {
          buffer_type = "split",
          page_size = 100,
          progress = {
            render_final_result = true,
          },
        },
        call_log = {
          enabled = true,
          size = 100,
        },
        window_layout = {
          drawer = {
            width = 0.3,
            height = 0.3,
          },
          editor = {
            width = 0.7,
            height = 0.7,
          },
          result = {
            width = 1.0,
            height = 0.3,
          },
        },
      })
      
      -- Dbeeのキーマッピング（安全チェック付き）
      vim.keymap.set('n', '<leader>db', function()
        local dbee_ok, dbee = pcall(require, "dbee")
        if dbee_ok then
          pcall(dbee.toggle)
        else
          vim.notify("Dbee not available", vim.log.levels.WARN)
        end
      end, { desc = "Dbee切り替え" })
      
      vim.keymap.set('n', '<leader>de', function()
        local dbee_ok, dbee = pcall(require, "dbee")
        if dbee_ok then
          pcall(dbee.execute)
        else
          vim.notify("Dbee not available", vim.log.levels.WARN)
        end
      end, { desc = "クエリ実行" })
    end,
  },

  -- データベース接続テスト用の設定例
  {
    "rcarriga/nvim-notify",
    config = function()
      -- データベース接続成功/失敗の通知
      vim.api.nvim_create_autocmd("User", {
        pattern = "DBUIConnectionSuccess",
        callback = function()
          require("notify")("データベース接続成功", "info", { title = "Database" })
        end,
      })
      
      vim.api.nvim_create_autocmd("User", {
        pattern = "DBUIConnectionError",
        callback = function()
          require("notify")("データベース接続エラー", "error", { title = "Database" })
        end,
      })
    end,
  },
}

-- サンプル接続設定（~/.config/nvim/database_connections.json）
--[[
{
  "dev_mysql": "mysql://user:password@localhost:3306/development",
  "prod_postgres": "postgresql://user:password@localhost:5432/production",
  "local_sqlite": "sqlite:///path/to/local.db",
  "test_db": "sqlite::memory:"
}
--]]