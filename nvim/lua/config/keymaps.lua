-- Keymaps are automatically loaded on the VeryLazy event leader key
vim.g.mapleader = " "

local keymap = vim.keymap

-- mode insert
keymap.set("i", "jj", "<ESC>", { silent = true })
keymap.set("i", "<C-l>", "<ESC>la", {})
keymap.set("i", "<C-h>", "<ESC>i", {})

-- mode normal
keymap.set("n", "<Space>h", "^", {})
keymap.set("n", "<Space>l", "$", {})
keymap.set("n", "<S-h>", "<S-h>", {})
keymap.set("n", "<S-l>", "<S-l>", {})
keymap.set("n", "<C-n>", "<C-d>", {})
keymap.set("n", "<C-h>", "<C-w>h", {})
keymap.set("n", "<C-l>", "<C-w>l", {})
keymap.set("n", "<C-j>", "<C-w>j", {})
keymap.set("n", "<C-k>", "<C-w>k", {})

-- lsp
vim.keymap.set("n", "gh", vim.lsp.buf.hover, { silent = true, desc = "LSP Hover" })
keymap.set("n", "gr", function()
	vim.lsp.buf.references()
end, { noremap = true, silent = true })
keymap.set("n", "gd", function()
	vim.lsp.buf.definition()
end, { noremap = true, silent = true })
keymap.set("n", "gn", function()
	vim.lsp.buf.rename()
end, { noremap = true, silent = true })
keymap.set("n", "go", function()
	vim.lsp.buf.code_action()
end, { noremap = true, silent = true, desc = "LSP: Code action" })
keymap.set(
	"n",
	"[e",
	"<cmd>lua vim.diagnostic.goto_next({severity = { min = vim.diagnostic.severity.ERROR, max = vim.diagnostic.severity.ERROR }})<CR>",
	{ noremap = true, silent = true }
)
keymap.set(
	"n",
	"]e",
	"<cmd>lua vim.diagnostic.goto_prev({severity = { min = vim.diagnostic.severity.ERROR, max = vim.diagnostic.severity.ERROR }})<CR>",
	{ noremap = true, silent = true }
)
vim.keymap.set("n", "[w", "<cmd>lua vim.diagnostic.goto_next()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "]w", "<cmd>lua vim.diagnostic.goto_prev()<CR>", { noremap = true, silent = true })

-- replace
vim.api.nvim_set_keymap("n", "*", ":keepjumps normal! mi*`i<CR>", { noremap = true, silent = true })

-- toggle fold
vim.api.nvim_set_keymap("n", "<C-[>", "za", { noremap = true, silent = true })

-- toggle terminal
vim.api.nvim_set_keymap("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })

-- toggle buffer
keymap.set("n", "tn", ":bnext<CR>", { noremap = true, silent = true })
keymap.set("n", "tp", ":bprevious<CR>", { noremap = true, silent = true })

-- paste action related
keymap.set("v", "p", '"_dP', { noremap = true, silent = true })

-- Telescope キーマップ
keymap.set("n", "<leader>f", function()
	require("telescope.builtin").find_files()
end, { noremap = true, silent = true, desc = "Telescope: Find files" })

-- init backspace key

---// VimScript //---
-- restart LSP Server
vim.cmd([[
  function! LspRestartServer(server_name) abort
    if empty(a:server_name)
      echo "Please provide a server name."
      return
    endif
    let clients = luaeval("vim.lsp.get_active_clients()")
    for client in clients
      if client.name == a:server_name
        luaeval("vim.lsp.stop_client(_A)", client.id)
        luaeval("require('lspconfig')[_A].launch()", a:server_name)
        echo "LSP server " . a:server_name . " restarted."
        return
      endif
    endfor
    echo "LSP server " . a:server_name . " not found."
  endfunction

  command! -nargs=1 LspRestart call LspRestartServer(<f-args>)
]])

--  recursive delete buffer
vim.cmd([[
  function! CloseAllBuffer()
    let current_buf = bufnr('%')
    let buffers = filter(range(1, bufnr('$')), 'buflisted(v:val)')

    for buf in buffers
      if buf != current_buf
        silent execute 'bdelete' buf
      endif
    endfor
  endfunction

  command! CloseAllBuffer call CloseAllBuffer()
]])
