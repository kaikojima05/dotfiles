return {
  {
    "mfussenegger/nvim-lint",
    lazy = true,
    event = "BufRead",
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        html = { "eslint_d" },
        css = { "eslint_d" },
        json = { "eslint_d" },
      }

      -- プロジェクトのルートディレクトリを .eslintrc.json を基準に設定
      local function set_cwd_to_project_root()
        local current_file = vim.fn.expand("%:p") -- 現在のファイルの絶対パス
        local search_path = current_file .. ";"   -- findfile の探索範囲を設定

        local project_root = vim.fn.fnamemodify(vim.fn.findfile(".eslintrc.json", search_path), ":p:h")
        if project_root and project_root ~= "" then
          vim.cmd("lcd " .. project_root)
        else
          vim.notify("Could not find .eslintrc.json starting from: " .. current_file, vim.log.levels.WARN)
        end
      end

      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          set_cwd_to_project_root()
          lint.try_lint()
        end,
      })
    end,
  },
}
