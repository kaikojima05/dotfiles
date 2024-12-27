vim.loader.enable()

if vim.g.vscode then
  vim.api.nvim_set_option("clipboard", "unnamedplus")
  vim.api.nvim_set_keymap("n", "di", 'di"', { noremap = true })
  vim.api.nvim_set_keymap("n", "di", "di{", { noremap = true })
  vim.api.nvim_set_keymap("n", "di", "di[", { noremap = true })
  vim.api.nvm_set_keympa()
else
  require("config.lazy")
end
