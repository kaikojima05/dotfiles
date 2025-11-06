-- TypeScript/TSX用のフォーマッター設定
-- Prettier/Biomeの自動選択機能を提供

local M = {}

-- 設定ファイルの存在チェック関数
---@param file string ファイル名
---@return boolean 存在するかどうか
function M.file_exists(file)
  local stat = vim.loop.fs_stat(file)
  return stat ~= nil
end

-- 階層的設定ファイル検索関数
---@param start_path string 開始パス
---@param config_files table 検索する設定ファイル名のリスト
---@return string|nil 見つかった設定ファイルのフルパス
function M.find_config_hierarchical(start_path, config_files)
  local current_dir = start_path
  local root_marker = "/"

  -- Windowsの場合
  if vim.fn.has("win32") == 1 then
    root_marker = string.match(start_path, "^%a:")
  end

  while current_dir and current_dir ~= root_marker do
    for _, config_file in ipairs(config_files) do
      local config_path = current_dir .. "/" .. config_file
      if M.file_exists(config_path) then
        return config_path
      end
    end

    local parent = vim.fn.fnamemodify(current_dir, ":h")
    if parent == current_dir then
      break
    end
    current_dir = parent
  end

  return nil
end

-- フォーマッターの設定ファイルチェック
---@param ctx conform.Context
---@return string|nil "prettier"|"biome"|nil
function M.detect_formatter(ctx)
  -- コンテキストとバッファの存在確認
  if not ctx or type(ctx) ~= "table" then
    return nil
  end

  local buf = ctx.buf
  -- バッファが無効な場合は現在のバッファを使用
  if type(buf) ~= "number" then
    buf = vim.api.nvim_get_current_buf()
  end

  -- 現在のファイルのディレクトリを取得
  local file_path = vim.api.nvim_buf_get_name(buf)
  local file_dir = vim.fn.fnamemodify(file_path, ":h")

  -- Prettier設定ファイルのリスト（package.json除く）
  local prettier_configs = {
    ".prettierrc",
    ".prettierrc.json",
    ".prettierrc.yml",
    ".prettierrc.yaml",
    ".prettierrc.json5",
    ".prettierrc.js",
    ".prettierrc.cjs",
    "prettier.config.js",
    "prettier.config.cjs",
    ".prettierrc.toml",
  }

  -- Prettier設定ファイルを階層的に検索
  local prettier_config = M.find_config_hierarchical(file_dir, prettier_configs)
  if prettier_config then
    return "prettier"
  end

  -- package.jsonのprettierConfigフィールドをチェック
  local package_json_path = M.find_config_hierarchical(file_dir, { "package.json" })
  if package_json_path then
    local ok, package_json = pcall(function()
      local content = vim.fn.readfile(package_json_path)
      return vim.fn.json_decode(table.concat(content, "\n"))
    end)
    if ok and package_json and package_json.prettierConfig then
      return "prettier"
    end
  end

  -- Biome設定ファイルを階層的に検索
  local biome_configs = {
    "biome.json",
    "biome.jsonc",
  }

  local biome_config = M.find_config_hierarchical(file_dir, biome_configs)
  if biome_config then
    return "biome"
  end

  return nil
end

-- TypeScript/TSXでサポートされる言語
local ts_filetypes = {
  "typescript",
  "typescriptreact",
  "javascript",
  "javascriptreact",
  "json",
  "jsonc",
}

return {
  -- Mason: フォーマッターのインストール
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "prettier", "biome" })
    end,
    config = function(_, opts)
      require("mason").setup(opts)
    end,
  },

  -- 自動フォーマットを無効化
  {
    "LazyVim/LazyVim",
    opts = {
      -- 自動フォーマットを無効化
      autoformat = false,
    },
  },

  -- Conform: フォーマッター設定
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      -- 保存時のフォーマットを無効化
      opts.format_on_save = false
      opts.format_after_save = false

      opts.formatters_by_ft = opts.formatters_by_ft or {}

      -- LSPフォーマッターの優先度を下げる（Prettier/Biomeが使えない場合のみ使用）
      opts.formatters_by_ft["_"] = opts.formatters_by_ft["_"] or {}
      table.insert(opts.formatters_by_ft["_"], { "lsp" })

      -- フォーマッターの設定
      opts.formatters = opts.formatters or {}

      -- Prettier設定
      opts.formatters.prettier = {
        condition = function(ctx)
          return M.detect_formatter(ctx) == "prettier"
        end,
      }

      -- Biome設定
      opts.formatters.biome = {
        condition = function(ctx)
          return M.detect_formatter(ctx) == "biome"
        end,
      }
    end,
    keys = {
      {
        "<leader>cf",
        name = "+format",
        desc = "フォーマットコマンド",
      },
      {
        "<leader>cfp",
        function()
          require("conform").format({
            formatters = { "prettier" },
            timeout_ms = 3000,
            bufnr = vim.api.nvim_get_current_buf(),
          })
        end,
        desc = "Prettierでフォーマット",
      },
      {
        "<leader>cfb",
        function()
          require("conform").format({
            formatters = { "biome" },
            timeout_ms = 3000,
            bufnr = vim.api.nvim_get_current_buf(),
          })
        end,
        desc = "Biomeでフォーマット",
      },
      {
        "<leader>cfl",
        function()
          require("conform").format({
            formatters = { "lsp" },
            timeout_ms = 3000,
            bufnr = vim.api.nvim_get_current_buf(), -- 明示的に現在のバッファを指定
          })
        end,
        desc = "LSPでフォーマット",
      },
    },
    init = function()
      -- Prettierでフォーマットするコマンド
      vim.api.nvim_create_user_command("FormatWithPrettier", function()
        require("conform").format({
          formatters = { "prettier" },
          timeout_ms = 3000,
          bufnr = vim.api.nvim_get_current_buf(),
        })
      end, { desc = "Format with Prettier" })

      -- Biomeでフォーマットするコマンド
      vim.api.nvim_create_user_command("FormatWithBiome", function()
        require("conform").format({
          formatters = { "biome" },
          timeout_ms = 3000,
          bufnr = vim.api.nvim_get_current_buf(),
        })
      end, { desc = "Format with Biome" })

      -- LSPでフォーマットするコマンド
      vim.api.nvim_create_user_command("FormatWithLSP", function()
        require("conform").format({
          formatters = { "lsp" },
          timeout_ms = 3000,
          bufnr = vim.api.nvim_get_current_buf(), -- 明示的に現在のバッファを指定
        })
      end, { desc = "Format with LSP" })

      -- 自動フォーマットを無効化
      vim.g.autoformat = false
    end,
  },
}
