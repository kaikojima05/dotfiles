return {
  -- 1. Deno を Neovim で動かすためのプラグイン
  { "vim-denops/denops.vim", lazy = false },

  -- 2. skkeleton 本体
  {
    "vim-skk/skkeleton",
    dependencies = { "vim-denops/denops.vim" },
    config = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "DenopsReady",
        callback = function()
          -- skkeleton の設定
          vim.fn["skkeleton#config"]({
            eggLikeNewline = true,
            registerConvertResult = true,
            globalDictionaries = { vim.fn.expand("~/.skk/SKK-JISYO.L") },
            userDictionary = vim.fn.expand("~/.skk/skkeleton"),
            immediatelyCancel = false,
          })
        end,
      })

      -- 日本語入力のトグル (Ctrl+i で オン/オフ切り替え)
      vim.keymap.set({ "i", "c", "t" }, "<C-i>", "<Plug>(skkeleton-toggle)", { desc = "Toggle skkeleton" })
    end,
  },
}
