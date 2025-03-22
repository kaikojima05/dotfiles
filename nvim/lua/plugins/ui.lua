return {
	{
		-- プラグイン指定
		"folke/noice.nvim",
		-- opts フィールドとして関数を渡す
		opts = function(_, opts)
			-- すでにある opts.routes = {} がなければ作る
			opts.routes = opts.routes or {}

			-- コマンドライン以外のイベントは全部スキップ
			table.insert(opts.routes, {
				filter = {
					cond = function(details)
						return details.event ~= "cmdline"
					end,
				},
				opts = { skip = true },
			})
		end,
	},

	{
		"rcarriga/nvim-notify",
		enabled = false,
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
