-- Keymaps are automatically loaded on the VeryLazy event

-- leader key
vim.g.mapleader = " "

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- mode insert
keymap.set("i", "jj", "<ESC>", { silent = true })
keymap.set("i", "<C-l>", "<ESC>la", {})
keymap.set("i", ",", ",<Space>", {})

-- mode normal
keymap.set("n", "<Space>h", "^", {})
keymap.set("n", "<Space>l", "$", {})
keymap.set("n", "dh", "d0", {})
keymap.set("n", "dl", "d$", {})
keymap.set("n", "ch", "c0", {})
keymap.set("n", "cl", "c$", {})
keymap.set("n", "nd", ":Explore<CR>", {})
keymap.set("n", "vv", ":vsp<CR>", {})
keymap.set("n", "vh", "<C-w>h", {})
keymap.set("n", "vl", "<C-w>l", {})
keymap.set("n", "le", "b", {})
keymap.set("n", "<S-h>", "<S-h>", {})
keymap.set("n", "<S-l>", "<S-l>", {})
keymap.set("n", "<C-n>", "<C-d>", {})

-- resize window
keymap.set("n", "<C-w><left>", "<C-w><")
keymap.set("n", "<C-w><right>", "<C-w>>")
keymap.set("n", "<C-w><up>", "<C-w>+")
keymap.set("n", "<C-w><down>", "<C-w>-")

-- new tab
keymap.set("n", "te", ":tabedit")
keymap.set("n", "<tab>", ":tabnext<Return>", opts)

-- lsp
keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>")
keymap.set("n", "lf", "<cmd>Lspsaga lsp_finder<CR>")
keymap.set("n", "rk", "<cmd>Lspsaga peek_definition<CR>")
keymap.set("n", "ga", "<cmd>Lspsaga code_action<CR>")
keymap.set("n", "gn", "<cmd>Lspsaga rename<CR>")
keymap.set("n", "ge", "<cmd>Lspsaga show_line_diagnostics<CR>")
keymap.set("n", "[e", "<cmd>Lspsaga diagnostic_jump_next<CR>")
keymap.set("n", "]e", "<cmd>Lspsaga diagnostic_jump_prev<CR>")
keymap.set("n", "E", "<cmd>lua vim.diagnostic.goto_prev({severity = { min = vim.diagnostic.severity.ERROR, max = vim.diagnostic.severity.ERROR }})<CR>", { noremap = true, silent = true })
keymap.set("n", "W", "<cmd>lua vim.diagnostic.goto_prev({severity = { min = vim.diagnostic.severity.WARNING, max = vim.diagnostic.severity.WARNING }})<CR>", { noremap = true, silent = true })

-- replace
vim.api.nvim_set_keymap("n", "*", ":keepjumps normal! mi*`i<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>gn", "cgn", { noremap = true, silent = true })

-- toggle fold
vim.api.nvim_set_keymap("n", "<C-]>", "za", { noremap = true, silent = true })

-- toggle terminal
vim.api.nvim_set_keymap("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })

-- toggle buffer
keymap.set("n", "<C-l>", ":bnext<CR>", { noremap = true, silent = true })
keymap.set("n", "<C-h>", ":bprevious<CR>", { noremap = true, silent = true })

-- delete buffer
keymap.set("n", "<C-w>", ":bd<CR>", { noremap = true, silent = true })

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

-- neotree alias
keymap.set("n", "<leader>tn", ":Neotree toggle<CR>", { desc = "Toggle Neotree" })

-- format
keymap.set("n", "co", ":Format<CR>", { noremap = true, silent = true })
