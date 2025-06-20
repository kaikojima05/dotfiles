return {
	{
		"folke/flash.nvim",
		enabled = false,
	},

	-- nvim-cmp completion enhancement
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
		opts = function(_, opts)
			local cmp = require("cmp")
			
			-- ソースの安全な初期化
			opts.sources = opts.sources or {}
			
			-- LSP補完の強化
			local sources = {
				{ name = "nvim_lsp", priority = 1000 },
				{ name = "luasnip", priority = 750 },
				{ name = "buffer", priority = 500 },
				{ name = "path", priority = 250 },
			}
			
			-- 既存のsourcesがある場合はマージ、ない場合は新規設定
			if #opts.sources > 0 then
				for _, source in ipairs(sources) do
					table.insert(opts.sources, source)
				end
			else
				opts.sources = sources
			end
			
			-- パフォーマンス最適化
			opts.performance = opts.performance or {}
			opts.performance.debounce = 60
			opts.performance.throttle = 30
			opts.performance.fetching_timeout = 500
			
			return opts
		end,
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
