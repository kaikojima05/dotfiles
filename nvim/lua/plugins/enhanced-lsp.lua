-- Enhanced LSP Configuration for IntelliJ IDEA-like experience
return {
  -- Mason LSP manager with smart conditional installation
  {
    "williamboman/mason.nvim",
    opts = function()
      -- プロジェクト検出関数
      local function has_file(filename)
        return vim.fn.filereadable(filename) == 1
      end
      
      local function has_directory(dirname)
        return vim.fn.isdirectory(dirname) == 1
      end
      
      local function detect_project_type()
        local cwd = vim.fn.getcwd()
        local project_types = {}
        
        -- Go プロジェクト検出
        if has_file(cwd .. "/go.mod") or has_file(cwd .. "/go.sum") or has_directory(cwd .. "/vendor") then
          table.insert(project_types, "go")
        end
        
        -- Rust プロジェクト検出
        if has_file(cwd .. "/Cargo.toml") or has_file(cwd .. "/Cargo.lock") then
          table.insert(project_types, "rust")
        end
        
        -- Node.js プロジェクト検出
        if has_file(cwd .. "/package.json") or has_file(cwd .. "/yarn.lock") or has_file(cwd .. "/pnpm-lock.yaml") then
          table.insert(project_types, "nodejs")
        end
        
        -- Python プロジェクト検出
        if has_file(cwd .. "/requirements.txt") or has_file(cwd .. "/pyproject.toml") or has_file(cwd .. "/setup.py") then
          table.insert(project_types, "python")
        end
        
        return project_types
      end
      
      -- 基本的なツールリスト（常にインストール）
      local base_tools = {
        -- 汎用言語サーバー
        "lua-language-server",
        "json-lsp",
        "yaml-language-server",
        
        -- 汎用フォーマッター
        "prettier",
        "stylua",
      }
      
      -- プロジェクト固有のツールマップ
      local project_tools = {
        go = {
          -- Go関連ツール（条件付き）
          "gopls",
          "gofumpt",
          "golangci-lint",
          "go-debug-adapter",
        },
        rust = {
          -- Rust関連ツール（条件付き）
          "rust-analyzer",
          "rustfmt",
          "codelldb",
        },
        nodejs = {
          -- Node.js関連ツール（条件付き）
          "typescript-language-server",
          "eslint_d",
          "node-debug2-adapter",
        },
        python = {
          -- Python関連ツール（条件付き）
          "pyright",
          "black",
          "isort",
          "pylint",
          "debugpy",
        }
      }
      
      -- Web開発ツール（package.jsonがある場合、または.html/.css/.jsファイルが存在する場合）
      local web_tools = {
        "tailwindcss-language-server",
      }
      
      -- 動的にインストールリストを構築
      local ensure_installed = {}
      
      -- 基本ツールを追加
      for _, tool in ipairs(base_tools) do
        table.insert(ensure_installed, tool)
      end
      
      -- プロジェクトタイプに応じたツールを追加
      local detected_types = detect_project_type()
      for _, project_type in ipairs(detected_types) do
        if project_tools[project_type] then
          for _, tool in ipairs(project_tools[project_type]) do
            -- 重複チェック
            local already_added = false
            for _, existing_tool in ipairs(ensure_installed) do
              if existing_tool == tool then
                already_added = true
                break
              end
            end
            if not already_added then
              table.insert(ensure_installed, tool)
            end
          end
        end
      end
      
      -- Web開発プロジェクトの検出
      local cwd = vim.fn.getcwd()
      if vim.tbl_contains(detected_types, "nodejs") or 
         has_file(cwd .. "/index.html") or 
         vim.fn.glob(cwd .. "/**/*.html", true, true)[1] or
         vim.fn.glob(cwd .. "/**/*.css", true, true)[1] then
        for _, tool in ipairs(web_tools) do
          local already_added = false
          for _, existing_tool in ipairs(ensure_installed) do
            if existing_tool == tool then
              already_added = true
              break
            end
          end
          if not already_added then
            table.insert(ensure_installed, tool)
          end
        end
      end
      
      return {
        ensure_installed = ensure_installed,
        automatic_installation = true,
        log_level = vim.log.levels.INFO,
        max_concurrent_installers = 4,
        install_root_dir = vim.fn.stdpath("data") .. "/mason",
        
        -- エラーハンドリング強化
        on_install_success = function(package, handle)
          vim.notify("Successfully installed " .. package.name, vim.log.levels.INFO, {
            title = "Mason",
            timeout = 2000,
          })
        end,
        
        on_install_failure = function(package, handle)
          vim.notify("Failed to install " .. package.name .. ". Continuing with other packages...", vim.log.levels.WARN, {
            title = "Mason",
            timeout = 5000,
          })
        end,
      }
    end,
  },

  -- Enhanced completion (安全な設定)
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    opts = function(_, opts)
      -- 安全なnilチェック
      opts = opts or {}
      
      -- 既存のformattingを保持しつつ安全に拡張
      if not opts.formatting then
        opts.formatting = {}
      end
      
      -- 既存のformatting.formatがあれば保持
      local existing_format = opts.formatting.format
      
      opts.formatting.format = function(entry, vim_item)
        -- 既存のフォーマッターが存在する場合は先に実行
        if existing_format then
          vim_item = existing_format(entry, vim_item)
        end
        
        -- IntelliJ IDEA風のアイコンを安全に追加
        local icons = {
          Text = "📝", Method = "🔧", Function = "⚡", Constructor = "🏗️",
          Field = "🏷️", Variable = "📦", Class = "🏛️", Interface = "🔌",
          Module = "📚", Property = "🎛️", Unit = "📐", Value = "💎",
          Enum = "📋", Keyword = "🔑", Snippet = "✂️", Color = "🎨",
          File = "📄", Reference = "📎", Folder = "📁", EnumMember = "🏷️",
          Constant = "💯", Struct = "🏗️", Event = "⚡", Operator = "➕",
          TypeParameter = "🎯",
        }
        
        -- 既存のkindテキストを保持
        local kind_text = vim_item.kind or ""
        local icon = icons[kind_text] or ""
        
        if icon ~= "" and not kind_text:find(icon) then
          vim_item.kind = icon .. " " .. kind_text
        end
        
        -- menuが設定されていない場合のみ設定
        if not vim_item.menu then
          vim_item.menu = ({
            buffer = "[Buffer]",
            nvim_lsp = "[LSP]",
            luasnip = "[Snippet]",
            nvim_lua = "[Lua]",
            path = "[Path]",
            cmdline = "[CMD]",
            ["vim-dadbod-completion"] = "[DB]",
          })[entry.source.name] or ""
        end
        
        return vim_item
      end
      
      return opts
    end,
  },

  -- LSP configuration (neoconf後に読み込み)
  {
    "neovim/nvim-lspconfig",
    priority = 900, -- neoconfより低い優先度
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = "Replace",
              },
              diagnostics = {
                globals = { "vim" },
              },
            },
          },
        },
        
        tsserver = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },
        
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
              },
            },
          },
        },
        
        gopls = {
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
              },
              staticcheck = true,
              gofumpt = true,
            },
          },
        },
      },
    },
  },

  -- Enhanced diagnostics
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("trouble").setup({
        icons = {
          indent = {
            middle = " ",
            last = " ",
            top = " ",
            ws = "│  ",
          },
        },
        modes = {
          diagnostics = {
            groups = {
              { "filename", format = "{file_icon} {basename:Title} {count}" },
            },
          },
        },
      })
      
      -- IntelliJ IDEA風のキーマッピング
      vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "診断一覧" })
      vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "バッファ診断" })
      vim.keymap.set("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "シンボル一覧" })
      vim.keymap.set("n", "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", { desc = "LSP定義/参照" })
    end,
  },

  -- Code actions
  {
    "aznhe21/actions-preview.nvim",
    config = function()
      require("actions-preview").setup({
        highlight_command = {
          -- deltaが利用できない場合のフォールバック
          function()
            local ok, delta = pcall(require, "actions-preview.highlight")
            if ok and delta.delta then
              return delta.delta()
            else
              return {}
            end
          end,
        },
        telescope = {
          sorting_strategy = "ascending",
          layout_strategy = "vertical",
          layout_config = {
            width = 0.8,
            height = 0.9,
            prompt_position = "top",
            preview_cutoff = 20,
            preview_height = function(_, _, max_lines)
              return max_lines - 15
            end,
          },
        },
      })
      
      vim.keymap.set({ "v", "n" }, "<leader>ca", require("actions-preview").code_actions, { desc = "コードアクション" })
    end,
  },

  -- Symbol outline
  {
    "simrat39/symbols-outline.nvim",
    config = function()
      require("symbols-outline").setup({
        highlight_hovered_item = true,
        show_guides = true,
        auto_preview = false,
        position = 'right',
        relative_width = true,
        width = 25,
        auto_close = false,
        show_numbers = false,
        show_relative_numbers = false,
        show_symbol_details = true,
        preview_bg_highlight = 'Pmenu',
        autofold_depth = nil,
        auto_unfold_hover = true,
        fold_markers = { '', '' },
        wrap = false,
        keymaps = {
          close = { "<Esc>", "q" },
          goto_location = "<Cr>",
          focus_location = "o",
          hover_symbol = "<C-space>",
          toggle_preview = "K",
          rename_symbol = "r",
          code_actions = "a",
          fold = "h",
          unfold = "l",
          fold_all = "W",
          unfold_all = "E",
          fold_reset = "R",
        },
        lsp_blacklist = {},
        symbol_blacklist = {},
        symbols = {
          File = { icon = "📄", hl = "@text.uri" },
          Module = { icon = "📚", hl = "@namespace" },
          Namespace = { icon = "📦", hl = "@namespace" },
          Package = { icon = "📦", hl = "@namespace" },
          Class = { icon = "🏛️", hl = "@type" },
          Method = { icon = "🔧", hl = "@method" },
          Property = { icon = "🎛️", hl = "@method" },
          Field = { icon = "🏷️", hl = "@field" },
          Constructor = { icon = "🏗️", hl = "@constructor" },
          Enum = { icon = "📋", hl = "@type" },
          Interface = { icon = "🔌", hl = "@type" },
          Function = { icon = "⚡", hl = "@function" },
          Variable = { icon = "📦", hl = "@constant" },
          Constant = { icon = "💯", hl = "@constant" },
          String = { icon = "📝", hl = "@string" },
          Number = { icon = "🔢", hl = "@number" },
          Boolean = { icon = "✓", hl = "@boolean" },
          Array = { icon = "📊", hl = "@constant" },
          Object = { icon = "📋", hl = "@type" },
          Key = { icon = "🔑", hl = "@type" },
          Null = { icon = "∅", hl = "@type" },
          EnumMember = { icon = "🏷️", hl = "@field" },
          Struct = { icon = "🏗️", hl = "@type" },
          Event = { icon = "⚡", hl = "@type" },
          Operator = { icon = "➕", hl = "@operator" },
          TypeParameter = { icon = "🎯", hl = "@parameter" },
        },
      })
      
      vim.keymap.set("n", "<leader>o", "<cmd>SymbolsOutline<cr>", { desc = "シンボルアウトライン" })
    end,
  },

  -- Enhanced formatting
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      
      -- フォーマッターの安全な設定
      local formatters = {
        lua = { "stylua" },
        python = { "isort", "black" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        go = { "gofumpt" },
        rust = { "rustfmt" },
      }
      
      -- 既存設定とマージ
      for ft, formatter in pairs(formatters) do
        opts.formatters_by_ft[ft] = formatter
      end
      
      opts.format_on_save = opts.format_on_save or {}
      opts.format_on_save.timeout_ms = 500
      opts.format_on_save.lsp_fallback = true
      
      return opts
    end,
  },
  
  -- LSP keymaps enhancement
  {
    "neovim/nvim-lspconfig",
    opts = function()
      -- IntelliJ IDEA風のキーマップを追加
      local keys = {
        { "gd", function() vim.lsp.buf.definition() end, desc = "定義へ移動" },
        { "gr", function() vim.lsp.buf.references() end, desc = "参照検索" },
        { "gI", function() vim.lsp.buf.implementation() end, desc = "実装へ移動" },
        { "gy", function() vim.lsp.buf.type_definition() end, desc = "型定義へ移動" },
        { "K", function() vim.lsp.buf.hover() end, desc = "ホバー情報" },
        { "<C-k>", function() vim.lsp.buf.signature_help() end, desc = "シグネチャヘルプ" },
        { "<leader>rn", function() vim.lsp.buf.rename() end, desc = "リネーム" },
        { "<leader>ca", function() vim.lsp.buf.code_action() end, desc = "コードアクション" },
        { "<leader>f", function() vim.lsp.buf.format({ async = true }) end, desc = "フォーマット" },
        { "[d", function() vim.diagnostic.goto_prev() end, desc = "前の診断" },
        { "]d", function() vim.diagnostic.goto_next() end, desc = "次の診断" },
        { "<leader>e", function() vim.diagnostic.open_float() end, desc = "診断詳細" },
        { "<leader>q", function() vim.diagnostic.setloclist() end, desc = "診断リスト" },
      }
      
      -- キーマップの自動設定
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          for _, key in ipairs(keys) do
            vim.keymap.set("n", key[1], key[2], vim.tbl_extend("force", opts, { desc = key.desc }))
          end
        end,
      })
    end,
  },
}