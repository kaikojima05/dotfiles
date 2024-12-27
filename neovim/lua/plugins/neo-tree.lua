return {
  "nvim-neo-tree/neo-tree.nvim",
  cmd = "Neotree",
  opts = {
    default_component_configs = {
      keymap = {
        ["<BS>"] = false, -- バックスペースキーのマッピングを無効化
      },
    },
    filesystem = {
      filtered_items = {
        visible = true,
        show_hidden_count = false,
        hide_dotfiles = false,
        hide_gitignored = false,
      },
    },
  },
}
