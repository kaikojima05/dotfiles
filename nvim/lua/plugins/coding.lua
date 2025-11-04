return {
	-- CopilotChat.nvim - GitHub Copilot Chat integration
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "canary",
		dependencies = {
			"zbirenbaum/copilot.lua",
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		cmd = {
			"CopilotChat",
			"CopilotChatToggle",
			"CopilotChatOpen",
			"CopilotChatClose",
		},
		keys = {
			{
				"<leader>ccc",
				"<cmd>CopilotChat<cr>",
				desc = "CopilotChat - Open chat",
			},
			{
				"<leader>ccx",
				"<cmd>CopilotChatClose<cr>",
				desc = "CopilotChat - Close chat",
			},
			{
				"<leader>cct",
				"<cmd>CopilotChatToggle<cr>",
				desc = "CopilotChat - Toggle chat",
			},
			{
				"<leader>ccq",
				function()
					local input = vim.fn.input("Quick Chat: ")
					if input ~= "" then
						require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
					end
				end,
				desc = "CopilotChat - Quick chat with buffer context",
			},
			{
				"<leader>ccp",
				function()
					local actions = require("CopilotChat.actions")
					require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
				end,
				desc = "CopilotChat - Prompt actions",
			},
			{
				"<leader>cca",
				function()
					local input = vim.fn.input("Chat with all buffers: ")
					if input ~= "" then
						-- 全バッファの内容を取得する関数
						local function get_all_buffers_content()
							local buffers = {}
							local buffer_list = vim.api.nvim_list_bufs()
							local max_content_length = 50000 -- 最大文字数制限
							local total_length = 0

							for _, buf in ipairs(buffer_list) do
								if
									vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_option(buf, "buflisted")
								then
									local filename = vim.api.nvim_buf_get_name(buf)
									if
										filename ~= ""
										and not filename:match("^term://")
										and not filename:match("copilot%-chat")
									then
										local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
										local content = table.concat(lines, "\n")
										if content:len() > 0 and total_length + content:len() < max_content_length then
											table.insert(buffers, {
												filename = vim.fn.fnamemodify(filename, ":t"), -- ファイル名のみ
												content = content,
											})
											total_length = total_length + content:len()
										end
									end
								end
							end
							return buffers
						end

						-- バッファ内容を事前に取得
						local buffers = get_all_buffers_content()
						local combined_content = ""
						for _, buf in ipairs(buffers) do
							combined_content = combined_content .. "=== " .. buf.filename .. " ===\n"
							combined_content = combined_content .. buf.content .. "\n\n"
						end

						-- CopilotChatを開いてから質問を送信
						require("CopilotChat").ask(
							input
								.. "\n\n以下のファイル内容を参考にしてください：\n\n"
								.. combined_content
						)
					end
				end,
				desc = "CopilotChat - Chat with all buffers context",
			},
			{
				"<leader>ccf",
				function()
					local input = vim.fn.input("Chat with filtered buffers (filetype): ")
					if input ~= "" then
						local filetype_filter = vim.fn.input("Filter by filetype (empty for all): ")

						local function get_filtered_buffers_content(ft_filter)
							local buffers = {}
							local buffer_list = vim.api.nvim_list_bufs()
							local max_content_length = 50000 -- 最大文字数制限
							local total_length = 0

							for _, buf in ipairs(buffer_list) do
								if
									vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_option(buf, "buflisted")
								then
									local filename = vim.api.nvim_buf_get_name(buf)
									local filetype = vim.api.nvim_buf_get_option(buf, "filetype")

									if
										filename ~= ""
										and not filename:match("^term://")
										and not filename:match("copilot%-chat")
									then
										if ft_filter == "" or filetype == ft_filter then
											local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
											local content = table.concat(lines, "\n")
											if
												content:len() > 0
												and total_length + content:len() < max_content_length
											then
												table.insert(buffers, {
													filename = vim.fn.fnamemodify(filename, ":t"), -- ファイル名のみ
													filetype = filetype,
													content = content,
												})
												total_length = total_length + content:len()
											end
										end
									end
								end
							end
							return buffers
						end

						-- バッファ内容を事前に取得
						local buffers = get_filtered_buffers_content(filetype_filter)
						local combined_content = ""
						for _, buf in ipairs(buffers) do
							combined_content = combined_content
								.. "=== "
								.. buf.filename
								.. " ("
								.. buf.filetype
								.. ") ===\n"
							combined_content = combined_content .. buf.content .. "\n\n"
						end

						local filter_info = filetype_filter ~= "" and " (filetype: " .. filetype_filter .. ")" or ""
						require("CopilotChat").ask(
							input
								.. "\n\n以下のファイル内容を参考にしてください"
								.. filter_info
								.. "：\n\n"
								.. combined_content
						)
					end
				end,
				desc = "CopilotChat - Chat with filtered buffers by filetype",
			},
		},
		opts = {
			debug = false, -- Enable debug logging
			-- Japanese prompts
			prompts = {
				Explain = {
					prompt = "/COPILOT_EXPLAIN カーソル上のコードの説明を段落をつけて書いてください。",
				},
				Tests = {
					prompt = "/COPILOT_TESTS カーソル上のコードの詳細な単体テスト関数を書いてください。",
				},
				Fix = {
					prompt = "/COPILOT_FIX このコードには問題があります。バグを修正したコードに書き換えてください。",
				},
				Optimize = {
					prompt = "/COPILOT_REFACTOR 選択したコードを最適化し、パフォーマンスと可読性を向上させてください。",
				},
				Docs = {
					prompt = "/COPILOT_REFACTOR 選択したコードのドキュメントを書いてください。ドキュメントをコメントとして追加した元のコードを含むコードブロックで回答してください。使用するプログラミング言語に最も適したドキュメントスタイルを使用してください（例：JavaScriptのJSDoc、Pythonのdocstringsなど）",
				},
				FixDiagnostic = {
					prompt = "ファイル内の次のような診断上の問題を解決してください：",
					selection = function()
						return require("CopilotChat.select").diagnostics()
					end,
				},
			},
		},
	},

	-- Incremental rename
	{
		"smjonas/inc-rename.nvim",
		cmd = "IncRename",
		config = true,
	},

	-- Go forward/backward with square brackets
	{
		"nvim-mini/mini.bracketed",
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

	-- Refactoring tools
	{
		"ThePrimeagen/refactoring.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		keys = {
			{
				"<leader>re",
				function()
					require("refactoring").refactor("Extract Function")
				end,
				mode = "x",
				desc = "Extract Function",
			},
			{
				"<leader>rf",
				function()
					require("refactoring").refactor("Extract Function To File")
				end,
				mode = "x",
				desc = "Extract Function To File",
			},
			{
				"<leader>rv",
				function()
					require("refactoring").refactor("Extract Variable")
				end,
				mode = "x",
				desc = "Extract Variable",
			},
			{
				"<leader>ri",
				function()
					require("refactoring").refactor("Inline Variable")
				end,
				mode = { "n", "x" },
				desc = "Inline Variable",
			},
		},
		opts = {},
	},

	-- Enhanced autopairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			local npairs = require("nvim-autopairs")
			npairs.setup({
				check_ts = true,
				ts_config = {
					lua = { "string", "source" },
					javascript = { "string", "template_string" },
					java = false,
				},
				disable_filetype = { "TelescopePrompt", "spectre_panel" },
				fast_wrap = {
					map = "<M-e>",
					chars = { "{", "[", "(", '"', "'" },
					pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
					offset = 0,
					end_key = "$",
					keys = "qwertyuiopzxcvbnmasdfghjkl",
					check_comma = true,
					highlight = "PmenuSel",
					highlight_grey = "LineNr",
				},
			})
		end,
	},

	-- Nvim colorizer for color preview
	{
		"NvChad/nvim-colorizer.lua",
		event = { "BufReadPost", "BufNewFile" },
		keys = {
			{
				"<leader>tc",
				"<cmd>ColorizerToggle<cr>",
				desc = "Toggle colorizer",
			},
		},
		config = function()
			require("colorizer").setup({
				"*",
				css = { rgb_fn = true },
				html = { names = false },
			})
		end,
	},

	-- Venv selector for Python development
	{
		"linux-cultist/venv-selector.nvim",
		cmd = "VenvSelect",
		opts = {
			name = {
				"venv",
				".venv",
				"env",
				".env",
			},
		},
		keys = {
			{
				"<leader>cv",
				"<cmd>:VenvSelect<cr>",
				desc = "Select VirtualEnv",
			},
		},
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
}
