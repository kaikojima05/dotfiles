return {
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      {
        "antosha417/nvim-lsp-file-operations",
        config = true,
      },
      {
        "jose-elias-alvarez/typescript.nvim",
      },
    },
    opts = function()
      ---@class PluginLspOpts
      local ret = {
        diagnostics = {
          underline = true,
          virtual_text = {
            spacing = 4,
            source = "if_many",
            prefix = "●",
          },
          severity_sort = true,
        },
        inlay_hints = {
          enabled = true,
        },
        document_highlight = {
          enabled = true,
        },
        capabilities = vim.lsp.protocol.make_client_capabilities(),
        format = {
          formatting_options = nil,
          timeout_ms = nil,
        },
        servers = {
          tsserver = {
            root_dir = function(...)
              return require("lspconfig.util").root_pattern(".git")(...)
            end,
            single_file_support = false,
            settings = {
              typescript = {
                inlayHints = {
                  includeInlayParameterNameHints = "literal",
                  includeInlayFunctionParameterTypeHints = true,
                  includeInlayPropertyDeclarationTypeHints = true,
                },
              },
              javascript = {
                inlayHints = {
                  includeInlayParameterNameHints = "all",
                  includeInlayFunctionParameterTypeHints = true,
                },
              },
            },
          },
          prismals = {
            settings = {
              prisma = {
                prismaFmtBinPath = "prisma-fmt",
              },
            },
          },
          lua_ls = {
            settings = {
              Lua = {
                workspace = {
                  checkThirdParty = false,
                },
                hint = {
                  enable = true,
                },
                diagnostics = {
                  globals = { "vim" },
                },
              },
            },
          },
          yamlls = {
            settings = {
              yaml = {
                keyOrdering = false,
              },
            },
          },
          intelephense = {
            settings = {
              intelephense = {
                files = {
                  maxSize = 1000000,
                },
              },
            },
          },
        },
        setup = {
          tsserver = function(_, opts)
            -- カスタマイズ例: TypeScript 用プラグインと統合
            require("typescript").setup({ server = opts })
            return true
          end,
        },
      }
      return ret
    end,
    config = function(_, opts)
      local lspconfig = require("lspconfig")

      -- サーバーごとの設定を適用
      for server, server_opts in pairs(opts.servers) do
        if opts.setup[server] then
          -- カスタムセットアップがある場合はそれを使用
          if opts.setup[server](server, server_opts) then
            goto continue
          end
        elseif opts.setup["*"] then
          -- フォールバックセットアップ
          if opts.setup["*"](server, server_opts) then
            goto continue
          end
        end
        -- 標準的なセットアップ
        lspconfig[server].setup(server_opts)
        ::continue::
      end
    end,
  },
}
