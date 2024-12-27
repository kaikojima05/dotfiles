return {
  {
    "stevearc/conform.nvim",
    lazy = false, -- 必ずロードする
    opts = function(_, opts)
      -- メッセージを表示するための on_success と on_error の設定
      -- フォーマッターをファイルタイプに紐付ける
      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        json = { "prettier" },
        markdown = { "typos" },
        text = { "typos" },
        lua = { "stylua" },
      })

      -- 成功/失敗時のメッセージを表示する設定を追加
      opts.on_success = function(formatter, bufnr)
        vim.notify(string.format("Formatted %s with %s", vim.api.nvim_buf_get_name(bufnr), formatter), vim.log.levels.INFO)
      end

      opts.on_error = function(formatter, bufnr, error)
        vim.notify(string.format("Error formatting %s with %s: %s", vim.api.nvim_buf_get_name(bufnr), formatter, error), vim.log.levels.ERROR)
      end
    end,
  },
}

