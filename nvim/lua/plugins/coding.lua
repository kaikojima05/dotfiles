return {
	{
		"folke/flash.nvim",
		enabled = false,
	},

	{
		"smjonas/inc-rename.nvim",
		enabled = false,
	},

	-- Go forward/backward with square brackets
	{
		"echasnovski/mini.bracketed",
		event = "BufReadPost",
		config = function()
			local bracketed = require("mini.bracketed")
			bracketed.setup({
				file = { suffix = "" },
				window = { suffix = "" },
				quickfix = { suffix = "" },
				yank = { suffix = "" },
				treesitter = { suffix = "n" },
			})
		end,
	},

	-- Better increase/descrease
	{
		"monaqa/dial.nvim",
    -- stylua: ignore
    keys = {
      { "<C-a>", function() return require("dial.map").inc_normal() end, expr = true, desc = "Increment" },
      { "<C-x>", function() return require("dial.map").dec_normal() end, expr = true, desc = "Decrement" },
    },
		config = function()
			local augend = require("dial.augend")
			require("dial.config").augends:register_group({
				default = {
					augend.integer.alias.decimal,
					augend.integer.alias.hex,
					augend.date.alias["%Y/%m/%d"],
					augend.constant.alias.bool,
					augend.semver.alias.semver,
					augend.constant.new({ elements = { "let", "const" } }),
				},
			})
		end,
	},

	-- copilot
	{
		"zbirenbaum/copilot.lua",
		opts = {
			suggestion = {
				auto_trigger = true,
				keymap = {
					accept = "<Tab>",
					accept_word = "<M-l>",
					accept_line = "<M-S-l>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
			},
			filetypes = {
				markdown = true,
				help = true,
			},
		},
	},

	-- formatter
	{
		"stevearc/conform.nvim",
		opts = function(_, opts)
			local web_formatter = { "biome", "prettierd", stop_after_first = true }

			-- `formatters_by_ft` に web_formatter を追加
			opts.formatters_by_ft = opts.formatters_by_ft or {}
			opts.formatters_by_ft.typescript = web_formatter
			opts.formatters_by_ft.javascript = web_formatter
			opts.formatters_by_ft.typescriptreact = web_formatter
			opts.formatters_by_ft.javascriptreact = web_formatter
			opts.formatters_by_ft.vue = web_formatter
			opts.formatters_by_ft.svelte = web_formatter
			opts.formatters_by_ft.json = web_formatter
			opts.formatters_by_ft.jsonc = web_formatter
			opts.formatters_by_ft.yaml = web_formatter
			opts.formatters_by_ft.html = web_formatter
			opts.formatters_by_ft.css = web_formatter
			opts.formatters_by_ft.scss = web_formatter
		end,
	},
}
