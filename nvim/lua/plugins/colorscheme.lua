return {
	{
		"projekt0n/github-nvim-theme",
		lazy = true,
		priority = 1000,
		config = function()
			vim.cmd("colorscheme github_dark")
		end,
	},
}
