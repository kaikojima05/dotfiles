-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = "*",
	command = "set nopaste",
})

-- Disable the concealing in some file formats
-- The default conceallevel is 3 in LazyVim
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "json", "jsonc", "markdown" },
	callback = function()
		vim.opt_local.conceallevel = 0
		if vim.bo.filetype == "markdown" then
			vim.opt_local.spell = false
		end
	end,
})

vim.api.nvim_create_user_command("Fm", function()
	local conform = require("conform")
	conform.format({
		lsp_fallback = true,
		async = true,
	})
end, {})

vim.cmd("cnoreabbrev fm Fm")
