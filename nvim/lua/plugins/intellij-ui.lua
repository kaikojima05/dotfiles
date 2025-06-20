-- IntelliJ IDEA風UI設定
return {
  -- ステータスラインの強化（IntelliJ IDEA風）
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- 安全なnilチェック
      opts = opts or {}
      
      local function safe_project_name()
        local ok, cwd = pcall(vim.fn.getcwd)
        if not ok or not cwd or cwd == "" then
          return ""
        end
        local project = cwd:match("([^/]+)$")
        return project and "📁 " .. project or ""
      end
      
      local function safe_db_status()
        local ok, db_ui_database = pcall(function() return vim.g.db_ui_database end)
        if ok and db_ui_database and type(db_ui_database) == "string" then
          local db_name = db_ui_database:match("([^/]+)$")
          return db_name and "🗄️ " .. db_name or ""
        end
        return ""
      end
      
      -- 既存のsectionsを保持しつつ拡張
      opts.sections = opts.sections or {}
      opts.sections = vim.tbl_deep_extend("force", opts.sections, {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { 
          { "filename", path = 1 },
          { safe_project_name, color = { fg = "#7aa2f7" } }
        },
        lualine_x = { 
          { safe_db_status, color = { fg = "#9ece6a" } },
          "encoding", 
          "fileformat", 
          "filetype" 
        },
        lualine_y = { "progress" },
        lualine_z = { "location" }
      })
      
      -- 既存のoptionsを保持しつつ拡張
      opts.options = opts.options or {}
      opts.options = vim.tbl_deep_extend("force", opts.options, {
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        globalstatus = true,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      })
      
      return opts
    end,
  },

  -- タブライン（IntelliJ IDEA風）
  {
    "akinsho/bufferline.nvim",
    opts = function(_, opts)
      -- 安全なnilチェック
      opts = opts or {}
      opts.options = vim.tbl_extend("force", opts.options or {}, {
        mode = "buffers",
        separator_style = "slant",
        always_show_bufferline = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        color_icons = true,
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
          local icon = level:match("error") and " " or " "
          return " " .. icon .. count
        end,
        custom_filter = function(buf_number)
          -- ファイルエクスプローラーなどを除外
          local buf_name = vim.fn.bufname(buf_number)
          if buf_name:match("NvimTree") or buf_name:match("neo%-tree") then
            return false
          end
          return true
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "📁 Project Explorer",
            text_align = "center",
            separator = true,
          },
          {
            filetype = "dbui",
            text = "🗄️ Database Explorer",
            text_align = "center",
            separator = true,
          },
        },
        hover = {
          enabled = true,
          delay = 200,
          reveal = {'close'}
        },
      })
      
      return opts
    end,
  },

  -- ウィンドウ管理（IntelliJ IDEA風）
  {
    "anuvyklack/windows.nvim",
    dependencies = {
      "anuvyklack/middleclass",
      "anuvyklack/animation.nvim"
    },
    config = function()
      require('windows').setup({
        autowidth = {
          enable = true,
          winwidth = 5,
          filetype = {
            help = 2,
          },
        },
        ignore = {
          buftype = { "quickfix" },
          filetype = { "NvimTree", "neo-tree", "undotree", "gundo" }
        },
        animation = {
          enable = true,
          duration = 300,
          fps = 30,
          easing = "in_out_sine"
        }
      })
      
      -- IntelliJ IDEA風のウィンドウ操作
      vim.keymap.set('n', '<C-w>z', ':WindowsMaximize<CR>', { desc = "ウィンドウ最大化" })
      vim.keymap.set('n', '<C-w>=', ':WindowsEqualize<CR>', { desc = "ウィンドウサイズ均等化" })
    end,
  },

  -- ポップアップメニューの強化
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      -- 安全なnilチェック
      opts = opts or {}
      local cmp = require("cmp")
      
      opts.window = {
        completion = {
          border = "rounded",
          winhighlight = "Normal:CmpPmenu,CursorLine:CmpSel,Search:None",
          scrollbar = true,
        },
        documentation = {
          border = "rounded",
          winhighlight = "Normal:CmpDoc",
        },
      }
      
      opts.formatting = {
        format = function(entry, vim_item)
          -- IntelliJ IDEA風のアイコン
          local icons = {
            Text = "📝",
            Method = "🔧",
            Function = "⚡",
            Constructor = "🏗️",
            Field = "🏷️",
            Variable = "📦",
            Class = "🏛️",
            Interface = "🔌",
            Module = "📚",
            Property = "🎛️",
            Unit = "📐",
            Value = "💎",
            Enum = "📋",
            Keyword = "🔑",
            Snippet = "✂️",
            Color = "🎨",
            File = "📄",
            Reference = "📎",
            Folder = "📁",
            EnumMember = "🏷️",
            Constant = "💯",
            Struct = "🏗️",
            Event = "⚡",
            Operator = "➕",
            TypeParameter = "🎯",
          }
          
          vim_item.kind = string.format("%s %s", icons[vim_item.kind] or "", vim_item.kind)
          vim_item.menu = ({
            buffer = "[Buffer]",
            nvim_lsp = "[LSP]",
            luasnip = "[Snippet]",
            nvim_lua = "[Lua]",
            latex_symbols = "[Latex]",
            ["vim-dadbod-completion"] = "[DB]",
          })[entry.source.name]
          
          return vim_item
        end,
      }
      
      return opts
    end,
  },

  -- ファイルエクスプローラーのアイコン強化
  {
    "nvim-tree/nvim-web-devicons",
    opts = {
      override = {
        sql = {
          icon = "🗄️",
          color = "#336791",
          cterm_color = "65",
          name = "Sql"
        },
        db = {
          icon = "🗄️",
          color = "#336791",
          cterm_color = "65",
          name = "Database"
        },
        sqlite = {
          icon = "🗄️",
          color = "#336791",
          cterm_color = "65",
          name = "Sqlite"
        },
      },
      override_by_filename = {
        [".env"] = {
          icon = "⚙️",
          color = "#faf743",
          cterm_color = "227",
          name = "Env"
        },
        ["docker-compose.yml"] = {
          icon = "🐳",
          color = "#0db7ed",
          cterm_color = "68",
          name = "DockerCompose"
        },
        ["Dockerfile"] = {
          icon = "🐳",
          color = "#0db7ed",
          cterm_color = "68",
          name = "Dockerfile"
        },
      },
    },
  },

  -- 通知システム（IntelliJ IDEA風）
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
      timeout = 5000,
      top_down = true
    },
  },


  -- IntelliJ IDEA風のキーマッピング統合
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      -- 安全なnilチェック
      opts = opts or {}
      local status_ok, wk = pcall(require, "which-key")
      if not status_ok then
        return opts
      end
      
      -- プロジェクト管理キー
      wk.register({
        ["<leader>p"] = {
          name = "📁 Project",
          p = { "<cmd>Telescope project<cr>", "プロジェクト切り替え" },
          f = { "<cmd>Telescope find_files<cr>", "ファイル検索" },
          g = { "<cmd>Telescope live_grep<cr>", "プロジェクト内検索" },
          r = { "<cmd>Telescope oldfiles<cr>", "最近のファイル" },
          t = { "<cmd>Neotree toggle<cr>", "ファイルツリー" },
          s = { "<cmd>SessionSave<cr>", "セッション保存" },
          l = { "<cmd>SessionRestore<cr>", "セッション復元" },
        },
        
        -- データベース管理キー
        ["<leader>d"] = {
          name = "🗄️ Database",
          u = { "<cmd>DBUIToggle<cr>", "DB UI切り替え" },
          f = { "<cmd>DBUIFindBuffer<cr>", "DBバッファ検索" },
          r = { "<cmd>DBUIRenameBuffer<cr>", "DBバッファ名前変更" },
          q = { "<cmd>DBUILastQueryInfo<cr>", "最後のクエリ情報" },
          e = { "<cmd>DBUIExecuteQuery<cr>", "クエリ実行" },
          b = { function() 
            local ok, dbee = pcall(require, "dbee")
            if ok then dbee.toggle() end
          end, "Dbee切り替え" },
        },
        
        -- ファイル操作キー（IntelliJ IDEA風）
        ["<C-S-N>"] = { "<cmd>Telescope find_files<cr>", "ファイル検索" },
        ["<C-S-F>"] = { "<cmd>Telescope live_grep<cr>", "プロジェクト内検索" },
        ["<C-E>"] = { "<cmd>Telescope buffers<cr>", "最近のファイル" },
        ["<C-S-O>"] = { "<cmd>Telescope project<cr>", "プロジェクト切り替え" },
        ["<C-1>"] = { "<cmd>Neotree toggle<cr>", "プロジェクトツリー" },
      }, { mode = "n" })
      
      return opts
    end,
  },

  -- ダッシュボード（IntelliJ IDEA風）
  {
    "goolord/alpha-nvim",
    opts = function(_, opts)
      local ok, dashboard = pcall(require, "alpha.themes.dashboard")
      if not ok then
        return opts or {}
      end
      
      -- IntelliJ IDEA風のロゴ
      dashboard.section.header.val = {
        "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
        "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
        "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
        "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
        "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
        "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
        "",
        "          🚀 Professional Development Environment",
      }
      
      if dashboard.button then
        dashboard.section.buttons.val = {
          dashboard.button("f", "📁 プロジェクト検索", ":Telescope find_files<CR>"),
          dashboard.button("e", "📄 ファイル検索", ":Telescope find_files<CR>"),
          dashboard.button("g", "🔍 プロジェクト内検索", ":Telescope live_grep<CR>"),
          dashboard.button("r", "🕒 最近のファイル", ":Telescope oldfiles<CR>"),
          dashboard.button("s", "⚙️ 設定", ":e $MYVIMRC<CR>"),
          dashboard.button("q", "❌ 終了", ":qa<CR>"),
        }
      else
        dashboard.section.buttons.val = {}
      end
      
      dashboard.section.footer.val = {
        "",
        "💡 Tip: Use <C-S-O> to quickly switch between projects",
        "🗄️ Tip: Use <leader>du to open database explorer",
      }
      
      return dashboard.config
    end,
  },
}