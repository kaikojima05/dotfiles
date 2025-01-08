vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  command = "set nopaste",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json", "jsonc", "markdown" },
  callback = function()
    vim.opt.conceallevel = 0
  end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    local swap_dir = vim.fn.expand("~/.local/state/nvim/swap//")
    vim.fn.system("find " .. swap_dir .. " -type f -name '*.swp' -delete")
  end,
})

-- 保存時の自動整形を無効化する
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact", "json", "jsonc", "yaml", "html", "css", "scss", "lua" },
  callback = function()
    vim.b.autoformat = false
  end,
})

-- 整形を手動で実行する
vim.api.nvim_create_user_command("Format", function()
  require("conform").format({
    async = true,
    lsp_fallback = false, -- LSP フォーマットにフォールバックしない
    on_success = function(formatters)
      vim.notify("Formatted with: " .. table.concat(formatters, ", "), vim.log.levels.INFO, { title = "Format" })
    end,
    on_error = function(formatters, error_msg)
      vim.notify("Error formatting with: " .. table.concat(formatters, ", ") .. "\n" .. error_msg, vim.log.levels.ERROR, { title = "Format Error" })
    end,
  })
end, {})

-- 編集中のファイルに対して typos を実行する
vim.api.nvim_create_user_command("TyposCheck", function()
  local current_file = vim.api.nvim_buf_get_name(0)
  if current_file == "" then
    vim.notify("No file is currently open", vim.log.levels.WARN, { title = "Typos" })
    return
  end

  -- カスタム辞書のパス
  local custom_dict = vim.fn.expand("~/.config/nvim/spell/.typos.toml")
  local dict_exists = vim.loop.fs_stat(custom_dict) ~= nil

  if not dict_exists then
    vim.notify("Custom dictionary not found: " .. custom_dict, vim.log.levels.ERROR, { title = "Typos Error" })
    return
  end

  local cmd = string.format("typos --config %s %s", custom_dict, current_file)
  local typos_output = {}

  -- typos の出力を処理
  local function process_data(data)
    if type(data) ~= "table" then
      return
    end
    for _, line in ipairs(data) do
      if line and line ~= "" then
        table.insert(typos_output, line)
      end
    end
  end

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      process_data(data)
    end,
    on_stderr = function(_, data)
      process_data(data)
    end,
    on_exit = function(_, _)
      if #typos_output > 0 then
        -- Typo がある場合はエラーレベルで通知
        vim.notify(table.concat(typos_output, "\n"), vim.log.levels.ERROR, { title = "Typo!" })
      end
    end,
  })
end, { desc = "Run typos on the current file" })
 
vim.api.nvim_create_user_command("ExcludeTypos", function(args)
  local custom_dict = vim.fn.expand("~/.config/nvim/spell/.typos.toml")

  if vim.fn.filereadable(custom_dict) == 0 then
    vim.notify("Custom dictionary not found: " .. custom_dict, vim.log.levels.ERROR, { title = "Typos Error" })
    return
  end

  local word = args.args
  if word == "" then
    vim.notify("No word specified to exclude", vim.log.levels.WARN, { title = "ExcludeTypos" })
    return
  end
  -- ファイル内容を行ごとに読み取る
  local lines = {}
  for line in io.lines(custom_dict) do
    table.insert(lines, line)
  end

  -- `default.extend-words` セクションを探して単語を追加
  local added = false
  for i = #lines, 1, -1 do
    if lines[i]:find("%[default%.extend%-words%]") then
      table.insert(lines, i + 1, "" .. word .. ' = "' .. word .. '"')
      added = true
      break
    end
  end

  -- セクションが存在しない場合、新しいセクションを追加
  if not added then
    table.insert(lines, "[default.extend-words]")
    table.insert(lines, "    " .. word .. ' = "' .. word .. '"')
  end

  -- 辞書ファイルに書き戻す
  local file = io.open(custom_dict, "w")
  if file then
    file:write(table.concat(lines, "\n") .. "\n")
    file:close()
    vim.notify('Word "' .. word .. '" added to default.extend-words', vim.log.levels.INFO, { title = "ExcludeTypos" })
  else
    vim.notify("Failed to write to " .. custom_dict, vim.log.levels.ERROR, { title = "Typos Error" })
  end
end, {
  nargs = 1,
  desc = "Add a word to the default.extend-words in typos.toml",
})

-- ファイル保存時に typos を実行する
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*", -- すべてのファイルで実行
  callback = function()
    vim.cmd("TyposCheck")
  end,
  desc = "Run TyposCheck after saving the file",
})
