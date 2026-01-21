local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- discipline.cowboy()

keymap.set("i", "jj", "<ESC>", { silent = true })
keymap.set("i", "<C-l>", "<Right>", {})
keymap.set("i", "<C-h>", "<Left>", {})

keymap.set({ "n", "v" }, "<Space>h", "^", {})
keymap.set({ "n", "v" }, "<Space>l", "$", {})
keymap.set("n", "x", '"_x')

-- toggle buffer
keymap.set("n", "tn", ":bnext<CR>", { noremap = true, silent = true })
keymap.set("n", "tp", ":bprevious<CR>", { noremap = true, silent = true })

keymap.set("n", "<Leader>a", "gg<S-v>G")

-- New tab
keymap.set("n", "te", ":tabedit")

-- Diagnostics
keymap.set("n", "<C-n>", function()
  vim.diagnostic.goto_next()
end, opts)
keymap.set("n", "<C-p>", function()
  vim.diagnostic.goto_prev()
end, opts)

-- LSP
keymap.set("n", "gh", function()
  vim.lsp.buf.hover({
    border = "rounded",
    max_width = 80,
    max_height = 20,
  })
end, { desc = "LSP Hover" })

-- Search optimization
keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Quick buffer navigation
keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
keymap.set("n", "<leader>ba", "<cmd>%bdelete|edit#|bdelete#<cr>", { desc = "Delete all buffer current" })

-- paste action related
keymap.set("v", "p", '"_dP', { noremap = true, silent = true })

-- terminal mode
keymap.set("t", "jj", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Fold toggle
keymap.set("n", "<C-]>", "za", { desc = "Toggle fold" })

-- Scroll half page
keymap.set("n", "<C-j>", "<C-d>", { noremap = true, silent = true })
keymap.set("n", "<C-k>", "<C-u>", { noremap = true, silent = true })

-- functions
keymap.set("n", "<C-i>", function()
  require("user.lsp").toggleInlayHints()
end)

vim.api.nvim_create_user_command("ToggleAutoformat", function()
  require("user.lsp").toggleAutoformat()
end, {})

-- vim-visual-multi: Map escape sequences from Ghostty
-- Cmd+D (sent as \x1b[100;9u from Ghostty)
keymap.set({ "n", "v" }, "\x1b[100;9u", "<Plug>(VM-Find-Under)", { remap = true })
