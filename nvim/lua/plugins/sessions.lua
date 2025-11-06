-- Session management with auto-session
return {
  -- Auto session management with keymaps
  {
    "rmagatti/auto-session",
    lazy = false,
    keys = {
      {
        "<leader>rs",
        "<cmd>SessionSave<cr>",
        desc = "Save session",
      },
      {
        "<leader>rr",
        "<cmd>SessionRestore<cr>",
        desc = "Restore session",
      },
      {
        "<leader>rd",
        "<cmd>SessionDelete<cr>",
        desc = "Delete session",
      },
    },
    opts = {
      log_level = "error",
      auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
      auto_session_use_git_branch = false,
      auto_session_enable_last_session = false,
      -- Disable auto restore to show dashboard on startup
      auto_restore = false,
      auto_save = true,
    },
  },
}
