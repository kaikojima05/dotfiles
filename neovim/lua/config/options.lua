-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- encoding
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

-- rows
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false

-- indent
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.shiftwidth = 2
vim.opt.breakindent = true

-- tab
vim.opt.smarttab = true
vim.opt.expandtab = true
vim.opt.tabstop = 2

-- search keyword
vim.opt.title = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.inccommand = "split"

-- file managtement
vim.opt.backup = false
vim.opt.backupskip = { "/tmp/*", "/private/tmp/*" }

-- status line
vim.opt.cmdheight = 1
vim.opt.laststatus = 2
vim.opt.showcmd = true

-- scroll
vim.opt.scrolloff = 10

-- shell
vim.opt.shell = "zsh"
