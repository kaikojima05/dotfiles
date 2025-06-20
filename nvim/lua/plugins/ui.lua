return {
	{
		"folke/noice.nvim",
		opts = function(_, opts)
			opts.routes = opts.routes or {}

			table.insert(opts.routes, {
				filter = {
					event = "notify",
					cond = function(details)
						return not (details.opts and details.opts.title == "LspSaga hover_doc")
					end,
				},
				opts = { skip = true },
			})

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
			-- セクション初期化を確保
			opts.sections = opts.sections or {}
			opts.sections.lualine_c = opts.sections.lualine_c or {}
			
			-- 配列の長さをチェックしてから設定
			if #opts.sections.lualine_c >= 4 then
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
			else
				-- 配列が足りない場合は追加
				table.insert(opts.sections.lualine_c, {
					LazyVim.lualine.pretty_path({
						length = 0,
						relative = "cwd",
						modified_hl = "MatchParen",
						directory_hl = "",
						filename_hl = "Bold",
						modified_sign = "",
						readonly_icon = " 󰌾 ",
					}),
				})
			end
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
