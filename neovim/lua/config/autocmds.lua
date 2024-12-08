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
  -- フォーマッターを選択し、notify.nvim を通じて出力
  vim.lsp.buf.format({
    async = true,
    filter = function(client)
      -- Notify を通じて使用するフォーマッター名を出力
      vim.notify("Formatting with: " .. client.name, vim.log.levels.INFO, { title = "Format" })
      return true
    end,
  })
end, {})
