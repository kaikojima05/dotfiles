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

-- Disable continuations
keymap.set("n", "<Leader>o", "o<Esc>^Da", opts)
keymap.set("n", "<Leader>O", "O<Esc>^Da", opts)

-- Jumplist
keymap.set("n", "<C-m>", "<C-i>", opts)

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
keymap.set("n", "go", function()
  -- Force use vim.lsp.buf.definition (without telescope)
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  if #clients > 0 then
    vim.lsp.buf.definition()
  else
    vim.notify("No LSP client attached", vim.log.levels.WARN)
  end
end, { desc = "LSP Go to Definition (native)" })

-- Search optimization
keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Quick buffer navigation
keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
keymap.set("n", "<leader>ba", "<cmd>%bdelete|edit#|bdelete#<cr>", { desc = "Delete all buffer current" })

-- toggle buffer
keymap.set("n", "tn", ":bnext<CR>", { noremap = true, silent = true })
keymap.set("n", "tp", ":bprevious<CR>", { noremap = true, silent = true })

-- paste action related
keymap.set("v", "p", '"_dP', { noremap = true, silent = true })

keymap.set(
  "n",
  "<C-;>",
  ";",
  { desc = "セミコロンは telescope で使用しているので、別のキーを割り当てる" }
)

-- terminal mode
keymap.set("t", "jj", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Fold toggle
keymap.set("n", "<C-[>", "za", { desc = "Toggle fold" })

-- Scroll half page
keymap.set("n", "J", "<C-d>", { noremap = true, silent = true })
keymap.set("n", "K", "<C-u>", { noremap = true, silent = true })

-- functions
keymap.set("n", "<leader>r", function()
  require("user.hsl").replaceHexWithHSL()
end)

keymap.set("n", "<C-i>", function()
  require("user.lsp").toggleInlayHints()
end)

vim.api.nvim_create_user_command("ToggleAutoformat", function()
  require("user.lsp").toggleAutoformat()
end, {})

-- vim-visual-multi: Map escape sequences from Ghostty
-- Cmd+D (sent as \x1b[100;9u from Ghostty)
keymap.set({ "n", "v" }, "\x1b[100;9u", "<Plug>(VM-Find-Under)", { remap = true })
