return {
	{
		"SmiteshP/nvim-navic",
		lazy = true,
		init = function()
			vim.g.navic_silence = true

			require("lazyvim.util").lsp.on_attach(function(client, buffer)
				if client.supports_method("textDocument/documentSymbol") then
					require("nvim-navic").attach(client, buffer)
				end
			end)
		end,
		lsp = {
			auto_attach = true,
		},
		depth_limit = 9,
		icons = {
			File = "󰈙 ",
			Module = " ",
			Namespace = "󰌗 ",
			Package = " ",
			Class = "󰌗 ",
			Method = "󰆧 ",
			Property = " ",
			Field = " ",
			Constructor = " ",
			Enum = "󰕘",
			Interface = "󰕘",
			Function = "󰊕 ",
			Variable = "󰆧 ",
			Constant = "󰏿 ",
			String = "󰀬 ",
			Number = "󰎠 ",
			Boolean = "◩ ",
			Array = "󰅪 ",
			Object = "󰅩 ",
			Key = "󰌋 ",
			Null = "󰟢 ",
			EnumMember = " ",
			Struct = "󰌗 ",
			Event = " ",
			Operator = "󰆕 ",
			TypeParameter = "󰊄 ",
		},
	},
}
