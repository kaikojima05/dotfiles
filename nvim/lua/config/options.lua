vim.g.mapleader = " "

vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

vim.opt.number = true
vim.opt.relativenumber = false

vim.opt.title = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.hlsearch = true
vim.opt.backup = false
vim.opt.showcmd = true
vim.opt.cmdheight = 1
vim.opt.laststatus = 3
vim.opt.expandtab = true
vim.opt.scrolloff = 10
vim.opt.shell = "/bin/zsh"
vim.opt.backupskip = { "/tmp/*", "/private/tmp/*" }
vim.opt.inccommand = "split"
vim.opt.ignorecase = true -- Case insensitive searching UNLESS /C or capital in search
vim.opt.smarttab = true
vim.opt.breakindent = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.wrap = false -- No Wrap lines
vim.opt.backspace = { "start", "eol", "indent" }
vim.opt.path:append({ "**" }) -- Finding files - Search down into subfolders
vim.opt.wildignore:append({ "*/node_modules/*" })
vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitright = true -- Put new windows right of current
vim.opt.splitkeep = "cursor"
vim.opt.mouse = "a" -- マウス操作を有効化

-- タブの可視化
vim.opt.list = true
vim.opt.listchars = {
  tab = "→ ",
}

-- Undercurl
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

vim.cmd([[au BufNewFile,BufRead *.astro setf astro]])
vim.cmd([[au BufNewFile,BufRead Podfile setf ruby]])

if vim.fn.has("nvim-0.8") == 1 then
  vim.opt.cmdheight = 0
end

-- File types
vim.filetype.add({
  extension = {
    mdx = "mdx",
    tf = "terraform",
    tfvars = "terraform",
    tfstate = "json",
  },
})

vim.g.lazyvim_prettier_needs_config = true
vim.g.lazyvim_picker = "telescope"
vim.g.lazyvim_cmp = "blink.cmp"

-- FloatBorder の背景を透明に（境界線の外側に色がはみ出ないように）
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    local border_fg = vim.api.nvim_get_hl(0, { name = "FloatBorder" }).fg
    vim.api.nvim_set_hl(0, "FloatBorder", { fg = border_fg, bg = "NONE" })
  end,
})
-- 初回ロード時にも適用
local border_fg = vim.api.nvim_get_hl(0, { name = "FloatBorder" }).fg or 0x545A68
vim.api.nvim_set_hl(0, "FloatBorder", { fg = border_fg, bg = "NONE" })

-- Floating window (hover など) で markdown のコードフェンスを非表示
vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function(args)
    local win = vim.fn.bufwinid(args.buf)
    if win ~= -1 then
      local win_config = vim.api.nvim_win_get_config(win)
      if win_config.relative ~= "" then
        vim.schedule(function()
          if vim.api.nvim_win_is_valid(win) then
            vim.wo[win].conceallevel = 2
            vim.wo[win].concealcursor = "niv"
          end
        end)
      end
    end
  end,
})

