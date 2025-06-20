return {
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      local refactoring = require("refactoring")
      
      -- セットアップ設定
      refactoring.setup({
        -- プロンプト関数の設定
        prompt_func_return_type = {
          go = false,
          java = false,
          cpp = false,
          c = false,
          h = false,
          hpp = false,
          cxx = false,
        },
        prompt_func_param_type = {
          go = false,
          java = false,
          cpp = false,
          c = false,
          h = false,
          hpp = false,
          cxx = false,
        },
        printf_statements = {},
        print_var_statements = {},
      })
      
      -- IntelliJ IDEA風キーマッピング
      vim.keymap.set("x", "<leader>re", ":Refactor extract ", { desc = "Extract function" })
      vim.keymap.set("x", "<leader>rf", ":Refactor extract_to_file ", { desc = "Extract to file" })
      vim.keymap.set("x", "<leader>rv", ":Refactor extract_var ", { desc = "Extract variable" })
      vim.keymap.set({ "n", "x" }, "<leader>ri", ":Refactor inline_var", { desc = "Inline variable" })
      vim.keymap.set("n", "<leader>rI", ":Refactor inline_func", { desc = "Inline function" })
      vim.keymap.set("n", "<leader>rb", ":Refactor extract_block", { desc = "Extract block" })
      vim.keymap.set("n", "<leader>rbf", ":Refactor extract_block_to_file", { desc = "Extract block to file" })
      
      -- Shift+F6 (IntelliJ IDEAのリネーム)
      vim.keymap.set("n", "<S-F6>", function()
        return ":IncRename " .. vim.fn.expand("<cword>")
      end, { expr = true, desc = "IntelliJ-style rename" })
      
      -- Ctrl+Alt+M (メソッド抽出)
      vim.keymap.set("x", "<C-A-m>", ":Refactor extract ", { desc = "Extract method (IntelliJ)" })
      
      -- Ctrl+Alt+V (変数抽出)
      vim.keymap.set("x", "<C-A-v>", ":Refactor extract_var ", { desc = "Extract variable (IntelliJ)" })
      
      -- Ctrl+Alt+C (定数抽出)
      vim.keymap.set("x", "<C-A-c>", function()
        local var_name = vim.fn.input("Constant name: ")
        if var_name ~= "" then
          vim.cmd("Refactor extract_var " .. var_name)
        end
      end, { desc = "Extract constant (IntelliJ)" })
      
      -- Ctrl+Alt+P (パラメータ抽出)
      vim.keymap.set("x", "<C-A-p>", function()
        local param_name = vim.fn.input("Parameter name: ")
        if param_name ~= "" then
          vim.cmd("Refactor extract " .. param_name)
        end
      end, { desc = "Extract parameter (IntelliJ)" })
    end,
  },
  
  -- LSP統合によるスマートリネーム
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    config = function()
      require("inc-rename").setup({
        cmd_name = "IncRename", -- コマンド名
        hl_group = "Substitute", -- ハイライトグループ
        preview_empty_name = false, -- 空の名前のプレビューを無効
        show_message = true, -- メッセージ表示を有効
        input_buffer_type = nil, -- dressingに依存しないように修正
        post_hook = function(result)
          -- リネーム後のフック処理の安全な実装
          if result and result.changes and type(result.changes) == "table" and #result.changes > 0 then
            vim.notify("Renamed in " .. #result.changes .. " locations", vim.log.levels.INFO)
          end
        end,
      })
    end,
  },
  
  -- 高度なコード解析とリファクタリング支援
  {
    "nvim-treesitter/nvim-treesitter-refactor",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-treesitter.configs").setup({
        refactor = {
          highlight_definitions = {
            enable = true,
            -- シンタックスハイライトの無効化を避ける
            clear_on_cursor_move = true,
          },
          highlight_current_scope = { enable = true },
          smart_rename = {
            enable = true,
            -- キーマップ: grr で変数のスマートリネーム
            keymaps = {
              smart_rename = "grr",
            },
          },
          navigation = {
            enable = true,
            -- キーマップ: gd で定義へ移動, gr で参照一覧
            keymaps = {
              goto_definition = "gnd",
              list_definitions = "gnD",
              list_definitions_toc = "gO",
              goto_next_usage = "<a-*>",
              goto_previous_usage = "<a-#>",
            },
          },
        },
      })
    end,
  },
  
  -- Telescope統合による高度な検索・リファクタリング
  {
    "nvim-telescope/telescope.nvim",
    optional = true,
    opts = function(_, opts)
      -- オプションの安全な初期化
      opts = opts or {}
      opts.extensions = opts.extensions or {}
      
      -- Refactoring extension for Telescope
      opts.extensions.refactoring = {
        -- Refactoring prompts
        prompt_func_return_type = {
          go = false,
          java = false,
          cpp = false,
          c = false,
        },
        prompt_func_param_type = {
          go = false,
          java = false,
          cpp = false,
          c = false,
        },
      }
      
      return opts
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      
      -- 安全にリファクタリングextensionをロード
      pcall(function()
        telescope.load_extension("refactoring")
      end)
      
      -- キーマップ追加（安全な実装）
      vim.keymap.set(
        {"n", "x"},
        "<leader>rr",
        function() 
          local ok, refactoring = pcall(require, 'telescope')
          if ok and refactoring.extensions and refactoring.extensions.refactoring then
            refactoring.extensions.refactoring.refactors()
          else
            vim.notify("Refactoring extension not available", vim.log.levels.WARN)
          end
        end,
        { desc = "Refactor menu" }
      )
    end,
  },
}