-- debugging-fixed.lua - シンプルで確実に動作するデバッグ設定
return {
  -- nvim-dap core (Mason依存関係を除去)
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- シンプルなDAP UI設定
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              "breakpoints",
              "stacks",
              "watches",
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              "repl",
              "console",
            },
            size = 0.25,
            position = "bottom",
          },
        },
      })

      -- バーチャルテキスト設定
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
      })

      -- DAP UI自動開閉
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- ブレークポイント設定
      vim.fn.sign_define('DapBreakpoint', {
        text = '🔴',
        texthl = 'DapBreakpoint',
        linehl = '',
        numhl = ''
      })
      vim.fn.sign_define('DapStopped', {
        text = '▶️',
        texthl = 'DapStopped',
        linehl = 'DapStopped',
        numhl = ''
      })

      -- F5-F9 キーマップ設定
      vim.keymap.set('n', '<F5>', function() dap.continue() end, { desc = "Debug: Continue" })
      vim.keymap.set('n', '<F6>', function() dap.step_over() end, { desc = "Debug: Step Over" })
      vim.keymap.set('n', '<F7>', function() dap.step_into() end, { desc = "Debug: Step Into" })
      vim.keymap.set('n', '<F8>', function() dap.step_out() end, { desc = "Debug: Step Out" })
      vim.keymap.set('n', '<F9>', function() dap.toggle_breakpoint() end, { desc = "Debug: Toggle Breakpoint" })
      
      -- 追加のデバッグキーマップ
      vim.keymap.set('n', '<leader>dr', function() dap.repl.open() end, { desc = "Debug: Open REPL" })
      vim.keymap.set('n', '<leader>du', function() dapui.toggle() end, { desc = "Debug: Toggle UI" })
      vim.keymap.set('n', '<leader>dt', function() dap.terminate() end, { desc = "Debug: Terminate" })

      -- 基本的なPython debugpy設定
      dap.adapters.python = {
        type = 'executable',
        command = 'python3',
        args = { '-m', 'debugpy.adapter' },
      }

      dap.configurations.python = {
        {
          type = 'python',
          request = 'launch',
          name = "Launch file",
          program = "${file}",
          pythonPath = function()
            return 'python3'
          end,
        },
      }

      print("✅ Debug configuration loaded successfully")
    end,
  },
}