-- Session management with auto-session
return {
	-- Auto session management with keymaps
	{
		"rmagatti/auto-session",
		lazy = false,
		keys = {
			{
				"<leader>qs",
				"<cmd>SessionSave<cr>",
				desc = "Save session",
			},
			{
				"<leader>qr",
				"<cmd>SessionRestore<cr>",
				desc = "Restore session",
			},
			{
				"<leader>qd",
				"<cmd>SessionDelete<cr>",
				desc = "Delete session",
			},
		},
		opts = {
			log_level = "error",
			auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
			auto_session_use_git_branch = false,
			auto_session_enable_last_session = false,
		},
	},
}