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
