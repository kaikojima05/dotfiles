-- project-simple.lua - シンプルで確実に動作するプロジェクト管理設定
return {
  -- Telescope (基本的な設定のみ)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require('telescope')
      local builtin = require('telescope.builtin')
      
      telescope.setup({
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { "truncate" },
        },
      })
      
      -- 基本キーマップ
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find Files" })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Live Grep" })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Buffers" })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "Help Tags" })
      vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = "Find Files" })
      
      print("✅ Telescope configuration loaded successfully")
    end,
  },

  -- Neo-tree (ファイルツリー)
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = false,
        enable_git_status = true,
        enable_diagnostics = true,
        
        window = {
          position = "left",
          width = 30,
          mappings = {
            ["<space>"] = "toggle_node",
            ["<2-LeftMouse>"] = "open",
            ["<cr>"] = "open",
            ["o"] = "open",
            ["S"] = "open_split",
            ["s"] = "open_vsplit",
            ["t"] = "open_tabnew",
            ["C"] = "close_node",
            ["z"] = "close_all_nodes",
            ["a"] = "add",
            ["A"] = "add_directory", 
            ["d"] = "delete",
            ["r"] = "rename",
            ["y"] = "copy_to_clipboard",
            ["x"] = "cut_to_clipboard",
            ["p"] = "paste_from_clipboard",
            ["q"] = "close_window",
            ["R"] = "refresh",
          }
        },
        
        filesystem = {
          filtered_items = {
            visible = false,
            hide_dotfiles = false,
            hide_gitignored = false,
            hide_by_name = {
              "node_modules"
            },
          },
          follow_current_file = true,
        },
      })
      
      -- Neo-tree キーマップ
      vim.keymap.set('n', 'nt', ':Neotree toggle<CR>', { desc = "Toggle NeoTree" })
      vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { desc = "Toggle File Tree" })
      vim.keymap.set('n', '<leader>o', ':Neotree focus<CR>', { desc = "Focus File Tree" })
      
      print("✅ Neo-tree configuration loaded successfully")
    end,
  },

  -- プロジェクト管理
  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup({
        detection_methods = { "pattern" },
        patterns = { ".git", "Makefile", "package.json", "go.mod", "Cargo.toml" },
        show_hidden = false,
        silent_chdir = true,
        scope_chdir = 'global',
      })
      
      print("✅ Project.nvim configuration loaded successfully")
    end,
  },
}