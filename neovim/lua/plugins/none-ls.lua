return {
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local function run_prettier()
        local file_path = vim.fn.expand("%:p")
        local cmd = "prettier --write " .. file_path
        vim.cmd("!" .. cmd)
        vim.notify("Formatted code", vim.log.levels.INFO, {
          title = "Manual format",
        })
      end

      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettierd,
        },
        on_attach = function(client, bufnr)
          -- disable the lsp format
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false

          -- setting keymap
          vim.api.nvim_buf_set_keymap(bufnr, "n", "ff", "", {
            noremap = true,
            silent = true,
            callback = run_prettier,
          })
        end,
      })

      -- Global keymap for manual format
      vim.api.nvim_set_keymap("n", "ff", ":lua run_prettier()<CR>", {
        noremap = true,
        silent = true,
      })
    end,
  },
}
