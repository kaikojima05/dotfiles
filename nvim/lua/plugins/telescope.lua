return {
  {
    "nvim-telescope/telescope.nvim",
    lazy = true, -- 遅延ロード
    cmd = "Telescope",
    keys = {
      { "<leader>fP", "<cmd>Telescope find_files<CR>", desc = "Find Plugin File" },
      { "<leader>ff", "<cmd>Telescope find_files hidden=true<CR>", desc = "Find Files" },
      { "<leader>r", "<cmd>Telescope live_grep<CR>", desc = "Live Grep" },
      { "\\\\", "<cmd>Telescope buffers<CR>", desc = "List Buffers" },
      { "T", "<cmd>Telescope help_tags<CR>", desc = "Help Tags" },
      { "<leader>pp", "<cmd>Telescope resume<CR>", desc = "Resume Picker" },
      { "se", "<cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
      { "S", "<cmd>Telescope treesitter<CR>", desc = "Treesitter Symbols" },
      { "sf", function()
        require("telescope").extensions.file_browser.file_browser({
          cwd = vim.fn.expand("%:p:h"),
          respect_gitignore = false,
          hidden = true,
          grouped = true,
          previewer = false,
          initial_mode = "normal",
          layout_config = { height = 40 },
        })
      end, desc = "File Browser" },
    },
    dependencies = {
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-file-browser.nvim",
    },
    config = function(_, opts)
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local fb_actions = require("telescope").extensions.file_browser.actions

      opts.defaults = {
        wrap_results = true,
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
      }

      opts.extensions = {
        file_browser = {
          theme = "dropdown",
          hijack_netrw = true,
          mappings = {
            ["n"] = {
              ["N"] = fb_actions.create,
              ["h"] = fb_actions.goto_parent_dir,
              ["/"] = function()
                vim.cmd("startinsert")
              end,
              ["<C-u>"] = function(prompt_bufnr)
                for i = 1, 10 do actions.move_selection_previous(prompt_bufnr) end
              end,
              ["<C-d>"] = function(prompt_bufnr)
                for i = 1, 10 do actions.move_selection_next(prompt_bufnr) end
              end,
              ["<PageUp>"] = actions.preview_scrolling_up,
              ["<PageDown>"] = actions.preview_scrolling_down,
            },
          },
        },
      }

      telescope.setup(opts)
      telescope.load_extension("fzf")
      telescope.load_extension("file_browser")
    end,
  },
}
