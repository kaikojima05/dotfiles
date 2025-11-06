return {
  -- Completely override LazyVim's snacks explorer to prevent auto-opening
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      -- Disable all auto-open functionality
      opts.explorer = vim.tbl_deep_extend("force", opts.explorer or {}, {
        win = {
          width = 30,
          height = 0.8,
        },
        -- Completely disable auto-open
        auto_open = false,
        replace_netrw = false,
      })

      -- Configure picker for explorer to exclude only node_modules
      opts.picker = vim.tbl_deep_extend("force", opts.picker or {}, {
        sources = {
          explorer = {
            hidden = true, -- show hidden files
            ignored = true, -- show git ignored files
            exclude = { "node_modules", ".git", ".vscode" }, -- exclude only node_modules
          },
        },
      })
      return opts
    end,
    init = function()
      -- Disable netrw completely
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      -- Handle directory opening manually with a more aggressive approach
      -- DISABLED: Auto-open explorer on directory launch
      -- vim.api.nvim_create_autocmd("VimEnter", {
      -- 	group = vim.api.nvim_create_augroup("CustomDirectoryHandler", { clear = true }),
      -- 	callback = function()
      -- 		-- Check if we started with a directory argument
      -- 		local args = vim.fn.argv()
      -- 		for _, arg in ipairs(args) do
      -- 			if vim.fn.isdirectory(arg) == 1 then
      -- 				-- Clear all buffers and open explorer immediately
      -- 				vim.schedule(function()
      -- 					-- Close all buffers
      -- 					vim.cmd("silent! %bdelete!")
      -- 					-- Open snacks explorer
      -- 					Snacks.explorer({ cwd = vim.fn.fnamemodify(arg, ":p") })
      -- 				end)
      -- 				break
      -- 			end
      -- 		end
      -- 	end,
      -- })
    end,
    keys = {
      {
        "<leader>fe",
        function()
          Snacks.explorer({ cwd = LazyVim.root() })
        end,
        desc = "Explorer Snacks (root dir)",
      },
      {
        "<leader>fE",
        function()
          Snacks.explorer()
        end,
        desc = "Explorer Snacks (cwd)",
      },
      { "<leader>e", "<leader>fe", desc = "Explorer Snacks (root dir)", remap = true },
      { "<leader>E", "<leader>fE", desc = "Explorer Snacks (cwd)", remap = true },
    },
  },
}
