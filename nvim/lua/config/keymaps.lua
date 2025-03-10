-- Keymaps are automatically loaded on the VeryLazy event leader key
vim.g.mapleader = " "

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- mode insert
keymap.set("i", "jj", "<ESC>", { silent = true })
keymap.set("i", "<C-l>", "<ESC>la", {})
keymap.set("i", "<C-h>", "<ESC>i", {})

-- mode normal
keymap.set("n", "<Space>h", "^", {})
keymap.set("n", "<Space>l", "$", {})
keymap.set("n", "<leader>vv", ":vsp<CR>", {})
keymap.set("n", "<S-h>", "<S-h>", {})
keymap.set("n", "<S-l>", "<S-l>", {})
keymap.set("n", "<C-n>", "<C-d>", {})

-- new tab
keymap.set("n", "te", ":tabedit")
keymap.set("n", "<tab>", ":tabnext<Return>", opts)

-- lsp
keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>")
keymap.set("n", "lf", "<cmd>lua vim.lsp.buf.references()<CR>")
keymap.set("n", "rk", "<cmd>lua vim.lsp.buf.definition()<CR>")
keymap.set("n", "ga", "<cmd>lua vim.lsp.buf.code_action()<CR>")
keymap.set("n", "gn", "<cmd>lua vim.lsp.buf.rename()<CR>")
keymap.set("n", "ge", "<cmd>lua vim.diagnostic.open_float()<CR>")
keymap.set("n", "[e", "<cmd>lua vim.diagnostic.goto_next()<CR>")
keymap.set("n", "]e", "<cmd>lua vim.diagnostic.goto_prev()<CR>")
keymap.set(
	"n",
	"E",
	"<cmd>lua vim.diagnostic.goto_prev({severity = { min = vim.diagnostic.severity.ERROR, max = vim.diagnostic.severity.ERROR }})<CR>",
	{ noremap = true, silent = true }
)
vim.keymap.set("n", "W", "<cmd>lua vim.diagnostic.goto_next()<CR>", { noremap = true, silent = true })

-- replace
vim.api.nvim_set_keymap("n", "*", ":keepjumps normal! mi*`i<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>wd", "cgn", { noremap = true, silent = true })

-- toggle fold
vim.api.nvim_set_keymap("n", "<C-[>", "za", { noremap = true, silent = true })

-- toggle terminal
vim.api.nvim_set_keymap("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })

-- toggle buffer
keymap.set("n", "<C-l>", ":bnext<CR>", { noremap = true, silent = true })
keymap.set("n", "<C-h>", ":bprevious<CR>", { noremap = true, silent = true })

-- paste action related
keymap.set("v", "p", '"_dP', { noremap = true, silent = true })

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

-- format
keymap.set("n", ":ff", ":Format<CR>", { noremap = true, silent = true })
