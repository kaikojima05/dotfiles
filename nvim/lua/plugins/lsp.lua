return {
  -- TODO: Mason やめる
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", false } }, -- LazyVim デフォルトを無効化
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        "stylua",
        "selene",
        "luacheck",
        "shellcheck",
        "shfmt",
        "tailwindcss-language-server",
        "css-lsp",
        "prisma-language-server",
        "intelephense",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")

      -- パッケージがインストールされるまで待つ
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            vim.schedule(function()
              p:install()
            end)
          end
        end
      end

      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      -- LazyVim のデフォルト設定を保持しつつ、TypeScript サーバーを除外
      opts.handlers = opts.handlers or {}
      -- TypeScript 関連サーバーは起動しない
      opts.handlers["ts_ls"] = function() end
      opts.handlers["vtsls"] = function() end
      opts.handlers["tsserver"] = function() end

      -- ensure_installed に tailwindcss を追加
      opts.ensure_installed = opts.ensure_installed or {}
      if not vim.tbl_contains(opts.ensure_installed, "tailwindcss") then
        table.insert(opts.ensure_installed, "tailwindcss")
      end
    end,
  },

  -- lsp servers
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      ---@type lspconfig.options
      servers = {
        -- Disable TypeScript LSP servers (use typescript-tools.nvim instead)
        tsserver = {
          enabled = false,
        },
        ts_ls = {
          enabled = false,
        },
        vtsls = {
          enabled = false,
        },
        cssls = {},
        tailwindcss = {
          filetypes = {
            "html",
            "css",
            "scss",
            "sass",
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "svelte",
            "vue",
          },
          -- callHierarchy 非対応のエラーを抑制
          handlers = {
            ["callHierarchy/incomingCalls"] = function() end,
            ["callHierarchy/outgoingCalls"] = function() end,
          },
        },
        html = {},
        yamlls = {
          settings = {
            yaml = {
              keyOrdering = false,
              schemas = require("schemastore").yaml.schemas(),
            },
          },
        },
        jsonls = {
          settings = {
            json = {
              schemas = require("schemastore").json.schemas(),
              validate = { enable = true },
            },
          },
        },
        prismals = {},
        intelephense = {
          settings = {
            intelephense = {
              files = {
                maxSize = 5000000,
              },
            },
          },
        },
        lua_ls = {
          -- enabled = false,
          single_file_support = true,
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                workspaceWord = true,
                callSnippet = "Both",
              },
              misc = {
                parameters = {
                  -- "--log-level=trace",
                },
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
              doc = {
                privateName = { "^_" },
              },
              type = {
                castNumberToInteger = true,
              },
              diagnostics = {
                disable = { "incomplete-signature-doc", "trailing-space" },
                -- enable = false,
                groupSeverity = {
                  strong = "Warning",
                  strict = "Warning",
                },
                groupFileStatus = {
                  ["ambiguity"] = "Opened",
                  ["await"] = "Opened",
                  ["codestyle"] = "None",
                  ["duplicate"] = "Opened",
                  ["global"] = "Opened",
                  ["luadoc"] = "Opened",
                  ["redefined"] = "Opened",
                  ["strict"] = "Opened",
                  ["strong"] = "Opened",
                  ["type-check"] = "Opened",
                  ["unbalanced"] = "Opened",
                  ["unused"] = "Opened",
                },
                unusedLocalExclude = { "_*" },
              },
              format = {
                enable = false,
                defaultConfig = {
                  indent_style = "space",
                  indent_size = "2",
                  continuation_indent_size = "2",
                },
              },
            },
          },
          ["*"] = {
            keys = {
              {
                "gd",
                function()
                  -- Check if any LSP client supports textDocument/definition
                  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
                  local has_definition = false

                  for _, client in ipairs(clients) do
                    if client.server_capabilities.definitionProvider then
                      has_definition = true
                      break
                    end
                  end

                  if has_definition then
                    -- Use telescope if LSP supports definition
                    require("telescope.builtin").lsp_definitions({ reuse_win = false })
                  else
                    -- Fallback to vim's built-in definition jump
                    vim.notify("LSP definition not available, using fallback", vim.log.levels.WARN)
                    vim.cmd("normal! gd")
                  end
                end,
                desc = "Goto Definition",
                has = "definitionProvider",
              },
            },
          },
        },
      },
      setup = {
        -- Disable TypeScript LSP servers (use typescript-tools.nvim instead)
        tsserver = function()
          return true -- return true to prevent default setup
        end,
        ts_ls = function()
          return true -- return true to prevent default setup
        end,
        vtsls = function()
          return true -- return true to prevent default setup
        end,
      },
    },
  },

  -- actions preview
  {
    "aznhe21/actions-preview.nvim",
    dependencies = { "telescope.nvim" },
    keys = {
      {
        "<leader>ca",
        function()
          require("actions-preview").code_actions()
        end,
        mode = { "v", "n" },
        desc = "Code Action Preview",
      },
    },
    opts = {
      telescope = {
        sorting_strategy = "ascending",
        layout_strategy = "vertical",
        layout_config = {
          width = 0.8,
          height = 0.9,
          prompt_position = "top",
          preview_cutoff = 20,
          preview_height = function(_, _, max_lines)
            return max_lines - 15
          end,
        },
      },
    },
  },

  -- Schema Store for JSON/YAML
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false, -- last release is way too old
  },
}
