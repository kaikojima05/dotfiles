return {
	{
		"folke/noice.nvim",
		opts = function(_, opts)
			opts.routes = opts.routes or {}

			-- hover_doc に関する通知だけ通す。それ以外は全部スキップ
			table.insert(opts.routes, {
				filter = {
					event = "notify",
					-- hover_doc 以外を検出してスキップ
					cond = function(details)
						return not (details.opts and details.opts.title == "LspSaga hover_doc")
					end,
				},
				opts = { skip = true },
			})

			-- hover_doc の表示を改善（LSPのドキュメント枠に枠線など）
			opts.presets = opts.presets or {}
			opts.presets.lsp_doc_border = true
		end,
	},

	{
		"rcarriga/nvim-notify",
		opts = {
			timeout = 7000,
		},
	},

	-- buffer line
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		opts = {
			options = {
				mode = "buffers",
				show_buffer_close_icons = true,
				show_close_icon = true,
			},
		},
	},

	-- filename
	{
		"b0o/incline.nvim",
		enabled = false,
	},

	-- statusline
	{
		"nvim-lualine/lualine.nvim",
		opts = function(_, opts)
			local LazyVim = require("lazyvim.util")
			opts.sections.lualine_c[4] = {
				LazyVim.lualine.pretty_path({
					length = 0,
					relative = "cwd",
					modified_hl = "MatchParen",
					directory_hl = "",
					filename_hl = "Bold",
					modified_sign = "",
					readonly_icon = " 󰌾 ",
				}),
			}
		end,
	},

	-- indent
	{
		"snacks.nvim",
		opts = {
			scroll = { enabled = false },
			indent = { enabled = false },
		},
		keys = {},
	},
}
