-- Disable LazyVim's default snacks explorer extra
return {
  -- Disable the default snacks explorer extra completely
  {
    "lazyvim.plugins.extras.editor.snacks_explorer",
    enabled = false,
  },

  -- buffer line
  {
    "akinsho/bufferline.nvim",
    enabled = false, -- bufferline.nvimを無効化
  },

  -- filename (無効化)
  {
    "b0o/incline.nvim",
    enabled = false, -- incline.nvimを無効化
  },
}
