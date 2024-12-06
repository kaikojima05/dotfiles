if vim.g.vscode then
  vim.api.nvim_set_option("clipboard", "unnamedplus")
  vim.api.nvim_set_keymap("n", "di", 'di"', { noremap = true })
  vim.api.nvim_set_keymap("n", "di", "di{", { noremap = true })
  vim.api.nvim_set_keymap("n", "di", "di[", { noremap = true })
  vim.api.nvim_set_keymap("i", "kk", "<ESC>la", {})
else
  -- bootstrap lazy.nvim, LazyVim and your plugins
  require("config.lazy")

  -- プロジェクトによってインデントが「半角スペース」か「タブ」かを使い分ける
  local function load_project_settings()
    -- プロジェクトのルートディレクトリを取得する
    local project_root = vim.fn.getcwd()
    local project_config_file = project_root .. "/.nvimrc.lua"

    -- 設定ファイルが存在する場合、その設定を読み込む
    if vim.fn.filereadable(project_config_file) == 1 then
      vim.cmd("source " .. project_config_file)
      vim.notify("Project-specific settings loaded from " .. project_config_file, "info", { title = "Neovim Config" })
    else
      vim.notify("Apply default-specific setting" .. project_config_file, "info", { title = "Neovim Config" })
    end
  end

  vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
    callback = load_project_settings,
  })
end
