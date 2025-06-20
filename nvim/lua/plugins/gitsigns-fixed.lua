-- gitsigns-fixed.lua - 安定したGit統合設定
return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- Git可用性チェック
      local git_available = vim.fn.executable("git") == 1
      if not git_available then
        vim.notify("Git not available, skipping Gitsigns", vim.log.levels.WARN)
        return
      end
      
      -- Gitリポジトリチェック
      local in_git_repo = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):match("true")
      
      local gitsigns_ok, gitsigns = pcall(require, "gitsigns")
      if not gitsigns_ok then
        vim.notify("Gitsigns not available", vim.log.levels.ERROR)
        return
      end
      
      gitsigns.setup({
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "?" },
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        watch_gitdir = {
          follow_files = true
        },
        attach_to_untracked = false,
        current_line_blame = false,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol',
          delay = 1000,
          ignore_whitespace = false,
        },
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil,
        max_file_length = 40000,
        preview_config = {
          border = 'rounded',
          style = 'minimal',
          relative = 'cursor',
          row = 0,
          col = 1
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end
          
          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, {expr=true, desc = "Next Git hunk"})
          
          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, {expr=true, desc = "Previous Git hunk"})
          
          -- Actions
          map('n', '<leader>hs', gs.stage_hunk, { desc = "Git: Stage hunk" })
          map('n', '<leader>hr', gs.reset_hunk, { desc = "Git: Reset hunk" })
          map('v', '<leader>hs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = "Git: Stage hunk" })
          map('v', '<leader>hr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = "Git: Reset hunk" })
          map('n', '<leader>hS', gs.stage_buffer, { desc = "Git: Stage buffer" })
          map('n', '<leader>hu', gs.undo_stage_hunk, { desc = "Git: Undo stage hunk" })
          map('n', '<leader>hR', gs.reset_buffer, { desc = "Git: Reset buffer" })
          map('n', '<leader>hp', gs.preview_hunk, { desc = "Git: Preview hunk" })
          map('n', '<leader>hb', function() gs.blame_line{full=true} end, { desc = "Git: Blame line" })
          map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = "Git: Toggle line blame" })
          map('n', '<leader>hd', gs.diffthis, { desc = "Git: Diff this" })
          map('n', '<leader>hD', function() gs.diffthis('~') end, { desc = "Git: Diff this (~)" })
          map('n', '<leader>td', gs.toggle_deleted, { desc = "Git: Toggle deleted" })
          
          -- Text object
          map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = "Git: Select hunk" })
        end
      })
      
      vim.notify("✅ Gitsigns configured successfully", vim.log.levels.INFO)
    end,
  },
}