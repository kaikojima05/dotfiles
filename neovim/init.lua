if vim.loader then
  vim.loader.enable()
end

if vim.g.vscode then
  vim.api.nvim_set_option("clipboard", "unnamedplus")
  vim.api.nvim_set_keymap("n", "di", 'di"', { noremap = true })
  vim.api.nvim_set_keymap("n", "di", "di{", { noremap = true })
  vim.api.nvim_set_keymap("n", "di", "di[", { noremap = true })
else
  require("config.lazy")
end
