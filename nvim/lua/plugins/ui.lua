return {
	-- messages, cmdline and the popupmenu
	{
		"folke/noice.nvim",
		opts = function(_, opts)
			table.insert(opts.routes, {
				filter = {
					event = "notify",
					find = "No information available",
				},
				opts = { skip = true },
			})

			local focused = true

			vim.api.nvim_create_autocmd("FocusGained", {
				callback = function()
					focused = true
				end,
			})

			vim.api.nvim_create_autocmd("FocusLost", {
				callback = function()
					focused = false
				end,
			})

			table.insert(opts.routes, 1, {
				filter = {
					cond = function()
						return not focused
					end,
				},
				view = "notify_send",
				opts = { stop = false },
			})

			opts.commands = {
				all = {
					-- options for the message history that you get with `:Noice`
					view = "split",
					opts = { enter = true, format = "details" },
					filter = {},
				},
			}

			opts.notify = {
				-- notify のデフォルト設定
				enabled = true,
				view = "notify",
			}

			opts.views = {
				notify = {
					backend = "notify",
					opts = {
						stages = "slide",
						fps = 60,
					},
				},
			}

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function(event)
					vim.schedule(function()
						require("noice.text.markdown").keys(event.buf)
					end)
				end,
			})

			opts.presets.lsp_doc_border = true
		end,
		dependencies = {
			"rcarriga/nvim-notify",
		},
	},

	{
		"rcarriga/nvim-notify",
		opts = {
			timeout = 3500,
			stages = "slide",
			top_down = true,
			render = "default",
			fps = 60,
      level = vim.log.levels.WARN
		},
	},

	{
		"snacks.nvim",
		opts = {
			indent = { enabled = false },
			input = { enabled = true },
			notifier = { enabled = true },
			picker = { enabled = true },
			scope = { enabled = true },
			scroll = { enabled = false },
			statuscolumn = { enabled = false },
			toggle = { map = vim.keymap.set },
			words = { enabled = true },
			explorer = {
				hidden = true,
				show_hidden = true,
			},
		},
		keys = {
			{
				"<leader>n",
				function()
					local snacks = require("snacks")
					if snacks.config.picker and snacks.config.picker.enabled then
						snacks.picker.notifications()
					else
						snacks.notifier.show_history()
					end
				end,
				desc = "Notification History",
			},
			{
				"<leader>un",
				function()
					require("snacks").notifier.hide()
				end,
				desc = "Dismiss All Notifications",
			},
		},
	},

	{
		"snacks.nvim",
		opts = {
			dashboard = {
				preset = {
					header = [[
	        ██████╗ ███████╗██╗   ██╗ █████╗ ███████╗██╗     ██╗███████╗███████╗
	        ██╔══██╗██╔════╝██║   ██║██╔══██╗██╔════╝██║     ██║██╔════╝██╔════╝
	        ██║  ██║█████╗  ██║   ██║███████║███████╗██║     ██║█████╗  █████╗
	        ██║  ██║██╔══╝  ╚██╗ ██╔╝██╔══██║╚════██║██║     ██║██╔══╝  ██╔══╝
	        ██████╔╝███████╗ ╚████╔╝ ██║  ██║███████║███████╗██║██║     ███████╗
	        ╚═════╝ ╚══════╝  ╚═══╝  ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝╚═╝     ╚══════╝
   ]],
				},
			},
		},
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

	-- mini.indentscope for showing current scope only
	{
		"echasnovski/mini.indentscope",
		version = false,
		event = "LazyFile",
		opts = {
			symbol = "│",
			options = {
				try_as_border = true,
				border = "both",
			},
			draw = {
				delay = 0,
				animation = function()
					return 0
				end,
			},
		},
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"help",
					"alpha",
					"dashboard",
					"neo-tree",
					"Trouble",
					"trouble",
					"lazy",
					"mason",
					"notify",
					"toggleterm",
					"lazyterm",
				},
				callback = function()
					vim.b.miniindentscope_disable = true
				end,
			})
		end,
	},

	-- gitsigns for showing git diff indicators
	{
		"lewis6991/gitsigns.nvim",
		event = "LazyFile",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
			signs_staged = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
			signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
			numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
			linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
			word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
			current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
			attach_to_untracked = true,
		},
	},

	-- statusline
	{
		"nvim-lualine/lualine.nvim",
		opts = function(_, opts)
			local LazyVim = require("lazyvim.util")

			opts.options = opts.options or {}
			opts.options.section_separators = { left = "" }
			opts.options.component_separators = { left = "" }

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
			opts.sections.lualine_c[5] = {}
			opts.sections.lualine_x = {}
			opts.sections.lualine_y = {}
			opts.sections.lualine_z = {}

			-- 上部に tabline としてバッファリストを表示
			opts.tabline = {
				lualine_a = {
					{
						"buffers",
						show_filename_only = true,
						hide_filename_extension = false,
						show_modified_status = true,
						mode = 0,
						max_length = vim.o.columns * 2 / 3,
						symbols = {
							modified = " ●",
							alternate_file = "#",
							directory = "",
						},
						separator = { right = "" },
						left_padding = 2,
						buffers_color = {
							active = { bg = "#58a6ff", fg = "#ffffff", gui = "bold" },
							inactive = { bg = "#2d2d2d", fg = "#888888" },
						},
						setions = { "error" },
					},
				},
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			}
		end,
	},

	{
		"folke/zen-mode.nvim",
		cmd = "ZenMode",
		opts = {
			plugins = {
				gitsigns = true,
				tmux = true,
				kitty = { enabled = false, font = "+2" },
			},
		},
		keys = { { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" } },
	},

	{
		"MeanderingProgrammer/render-markdown.nvim",
		enabled = true,
	},

	-- Enhanced which-key configuration (v3 compatible)
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			plugins = { spelling = true },
			spec = {
				{ "g", group = "+goto" },
				{ "gz", group = "+surround" },
				{ "]", group = "+next" },
				{ "[", group = "+prev" },
				{ "<leader><tab>", group = "+tabs" },
				{ "<leader>b", group = "+buffer" },
				{ "<leader>c", group = "+code" },
				{ "<leader>f", group = "+file/find" },
				{ "<leader>g", group = "+git" },
				{ "<leader>gh", group = "+hunks" },
				{ "<leader>q", group = "+quit/session" },
				{ "<leader>s", group = "+search" },
				{ "<leader>t", group = "+toggle" },
				{ "<leader>u", group = "+ui" },
				{ "<leader>w", group = "+windows" },
				{ "<leader>x", group = "+diagnostics/quickfix" },
			},
		},
	},
}
