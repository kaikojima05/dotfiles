-- Neoconf setup with fallback for lspconfig.util module
return {
  {
    "folke/neoconf.nvim",
    priority = 1001, -- Highest priority to load first
    lazy = false,    -- Load immediately
    init = function()
      -- Create a fallback for lspconfig.util before neoconf loads
      local function create_lspconfig_fallback()
        if not pcall(require, "lspconfig.util") then
          -- Create a minimal fallback for lspconfig.util
          package.preload["lspconfig.util"] = function()
            return {
              root_pattern = function(...)
                local patterns = {...}
                return function(path)
                  path = path or vim.fn.getcwd()
                  for _, pattern in ipairs(patterns) do
                    local found = vim.fn.finddir(pattern, path .. ";")
                    if found ~= "" then
                      return vim.fn.fnamemodify(found, ":h")
                    end
                    local found_file = vim.fn.findfile(pattern, path .. ";")
                    if found_file ~= "" then
                      return vim.fn.fnamemodify(found_file, ":h")
                    end
                  end
                  return path
                end
              end,
              available_servers = function()
                return {}
              end,
              add_hook_before = function(fn, hook)
                return function(...)
                  if hook then hook(...) end
                  if fn then return fn(...) end
                end
              end,
              on_setup = function() end
            }
          end
        end
      end
      
      create_lspconfig_fallback()
    end,
    config = function()
      require("neoconf").setup({
        -- プロジェクト固有の設定を自動読み込み
        import = {
          vscode = true,
          coc = true,
          nlsp = true,
        },
        live_reload = true,
        filetype_jsonc = true,
        plugins = {
          lspconfig = {
            enabled = true,
          },
          jsonls = {
            enabled = true,
            configured_servers_only = true,
          },
          lua_ls = {
            enabled_for_neovim_config = true,
          },
        },
      })
    end,
  },
}