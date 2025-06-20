-- プロジェクト型自動検出システム
-- ファイル存在チェックベースの言語判定と必要な言語サーバーのみインストール

local M = {}

-- プロジェクト型検出ルール
local project_patterns = {
  -- Go プロジェクト
  go = {
    patterns = { "go.mod", "go.sum", "main.go" },
    lsp_servers = { "gopls" },
    formatters = { "gofumpt", "goimports" },
    linters = { "golangci-lint" },
    debuggers = { "delve" },
    description = "Go プロジェクト"
  },
  
  -- TypeScript/JavaScript プロジェクト
  typescript = {
    patterns = { "package.json", "tsconfig.json", "yarn.lock", "package-lock.json" },
    lsp_servers = { "typescript-language-server", "eslint" },
    formatters = { "prettier" },
    linters = { "eslint_d" },
    description = "TypeScript/JavaScript プロジェクト"
  },
  
  -- Python プロジェクト
  python = {
    patterns = { "pyproject.toml", "requirements.txt", "setup.py", "poetry.lock", "Pipfile" },
    lsp_servers = { "pyright" },
    formatters = { "black", "isort" },
    linters = { "flake8", "mypy" },
    debuggers = { "debugpy" },
    description = "Python プロジェクト"
  },
  
  -- Rust プロジェクト
  rust = {
    patterns = { "Cargo.toml", "Cargo.lock" },
    lsp_servers = { "rust-analyzer" },
    formatters = { "rustfmt" },
    description = "Rust プロジェクト"
  },
  
  -- Lua プロジェクト
  lua = {
    patterns = { "init.lua", ".luarc.json", "stylua.toml" },
    lsp_servers = { "lua-language-server" },
    formatters = { "stylua" },
    linters = { "luacheck" },
    description = "Lua プロジェクト"
  },
  
  -- C/C++ プロジェクト
  cpp = {
    patterns = { "CMakeLists.txt", "Makefile", "compile_commands.json", "*.vcxproj" },
    lsp_servers = { "clangd" },
    formatters = { "clang-format" },
    description = "C/C++ プロジェクト"
  },
  
  -- Java プロジェクト
  java = {
    patterns = { "pom.xml", "build.gradle", "build.gradle.kts", ".gradle" },
    lsp_servers = { "jdtls" },
    formatters = { "google-java-format" },
    description = "Java プロジェクト"
  },
  
  -- Ruby プロジェクト
  ruby = {
    patterns = { "Gemfile", "Gemfile.lock", "Rakefile", ".ruby-version" },
    lsp_servers = { "solargraph" },
    formatters = { "rubocop" },
    description = "Ruby プロジェクト"
  },
  
  -- PHP プロジェクト
  php = {
    patterns = { "composer.json", "composer.lock" },
    lsp_servers = { "intelephense" },
    formatters = { "php-cs-fixer" },
    description = "PHP プロジェクト"
  },
  
  -- Docker プロジェクト
  docker = {
    patterns = { "Dockerfile", "docker-compose.yml", "docker-compose.yaml", ".dockerignore" },
    lsp_servers = { "dockerls", "docker-compose-language-service" },
    description = "Docker プロジェクト"
  },
  
  -- YAML/JSON プロジェクト
  config = {
    patterns = { ".github/workflows", "ansible.cfg", "*.ansible.yml" },
    lsp_servers = { "yamlls", "jsonls" },
    formatters = { "yamlfmt" },
    description = "設定ファイルプロジェクト"
  }
}

-- ファイル・ディレクトリ存在チェック
local function file_exists(path)
  local stat = vim.loop.fs_stat(path)
  return stat ~= nil and stat.type == "file"
end

local function dir_exists(path)
  local stat = vim.loop.fs_stat(path)
  return stat ~= nil and stat.type == "directory"
end

local function path_exists(path)
  return file_exists(path) or dir_exists(path)
end

-- プロジェクトルートから相対パスでパターンをチェック
local function check_pattern_in_project(pattern, project_root)
  project_root = project_root or vim.fn.getcwd()
  
  -- グロブパターンの場合
  if pattern:match("%*") or pattern:match("%?") then
    local matches = vim.fn.glob(project_root .. "/" .. pattern, false, true)
    return #matches > 0
  end
  
  -- 直接パスの場合
  local full_path = project_root .. "/" .. pattern
  return path_exists(full_path)
end

-- プロジェクト型を検出
function M.detect_project_types(project_root)
  project_root = project_root or vim.fn.getcwd()
  local detected_types = {}
  
  for type_name, config in pairs(project_patterns) do
    local matches = 0
    local total_patterns = #config.patterns
    
    for _, pattern in ipairs(config.patterns) do
      if check_pattern_in_project(pattern, project_root) then
        matches = matches + 1
      end
    end
    
    -- 少なくとも1つのパターンがマッチしたらプロジェクト型として判定
    if matches > 0 then
      detected_types[type_name] = {
        config = config,
        confidence = matches / total_patterns,
        matches = matches,
        total = total_patterns
      }
    end
  end
  
  return detected_types
end

-- 検出されたプロジェクト型から必要なツールを収集
function M.get_required_tools(detected_types)
  local tools = {
    lsp_servers = {},
    formatters = {},
    linters = {},
    debuggers = {}
  }
  
  for type_name, type_info in pairs(detected_types) do
    local config = type_info.config
    
    -- LSP サーバー
    if config.lsp_servers then
      for _, server in ipairs(config.lsp_servers) do
        if not vim.tbl_contains(tools.lsp_servers, server) then
          table.insert(tools.lsp_servers, server)
        end
      end
    end
    
    -- フォーマッター
    if config.formatters then
      for _, formatter in ipairs(config.formatters) do
        if not vim.tbl_contains(tools.formatters, formatter) then
          table.insert(tools.formatters, formatter)
        end
      end
    end
    
    -- リンター
    if config.linters then
      for _, linter in ipairs(config.linters) do
        if not vim.tbl_contains(tools.linters, linter) then
          table.insert(tools.linters, linter)
        end
      end
    end
    
    -- デバッガー
    if config.debuggers then
      for _, debugger in ipairs(config.debuggers) do
        if not vim.tbl_contains(tools.debuggers, debugger) then
          table.insert(tools.debuggers, debugger)
        end
      end
    end
  end
  
  return tools
end

-- Mason ensure_installed リストを動的生成
function M.generate_mason_ensure_installed()
  local detected_types = M.detect_project_types()
  local required_tools = M.get_required_tools(detected_types)
  
  -- 全ツールを統合
  local ensure_installed = {}
  
  for _, server in ipairs(required_tools.lsp_servers) do
    table.insert(ensure_installed, server)
  end
  
  for _, formatter in ipairs(required_tools.formatters) do
    table.insert(ensure_installed, formatter)
  end
  
  for _, linter in ipairs(required_tools.linters) do
    table.insert(ensure_installed, linter)
  end
  
  for _, debugger in ipairs(required_tools.debuggers) do
    table.insert(ensure_installed, debugger)
  end
  
  -- 基本的なツールは常に含める
  local essential_tools = {
    "lua-language-server", -- Neovim 設定用
    "stylua", -- Lua フォーマッター
  }
  
  for _, tool in ipairs(essential_tools) do
    if not vim.tbl_contains(ensure_installed, tool) then
      table.insert(ensure_installed, tool)
    end
  end
  
  return ensure_installed
end

-- プロジェクト情報を表示
function M.show_project_info()
  local detected_types = M.detect_project_types()
  local required_tools = M.get_required_tools(detected_types)
  
  print("🔍 プロジェクト型検出結果:")
  print("=====================================")
  
  if vim.tbl_isempty(detected_types) then
    print("❌ プロジェクト型が検出されませんでした")
    return
  end
  
  for type_name, type_info in pairs(detected_types) do
    local confidence_percent = math.floor(type_info.confidence * 100)
    print(string.format("✅ %s (%s) - 信頼度: %d%% (%d/%d)", 
      type_name, 
      type_info.config.description,
      confidence_percent,
      type_info.matches,
      type_info.total
    ))
  end
  
  print("\n🛠️ インストールされるツール:")
  print("LSP Servers: " .. (#required_tools.lsp_servers > 0 and table.concat(required_tools.lsp_servers, ", ") or "なし"))
  print("Formatters: " .. (#required_tools.formatters > 0 and table.concat(required_tools.formatters, ", ") or "なし"))
  print("Linters: " .. (#required_tools.linters > 0 and table.concat(required_tools.linters, ", ") or "なし"))
  print("Debuggers: " .. (#required_tools.debuggers > 0 and table.concat(required_tools.debuggers, ", ") or "なし"))
  
  local total_tools = #required_tools.lsp_servers + #required_tools.formatters + #required_tools.linters + #required_tools.debuggers
  print(string.format("\n📊 総計: %d個のツール", total_tools))
end

-- プロジェクト変更時の自動検出
function M.setup_auto_detection()
  vim.api.nvim_create_autocmd({"DirChanged", "VimEnter"}, {
    group = vim.api.nvim_create_augroup("ProjectDetector", { clear = true }),
    callback = function()
      -- 少し遅延させて安定化
      vim.defer_fn(function()
        local detected_types = M.detect_project_types()
        if not vim.tbl_isempty(detected_types) then
          local types = vim.tbl_keys(detected_types)
          vim.notify(
            string.format("🔍 プロジェクト型検出: %s", table.concat(types, ", ")),
            vim.log.levels.INFO,
            { title = "Project Detector" }
          )
        end
      end, 500)
    end,
  })
end

-- Mason関連のプラグインを一時的に無効化（エラー修正のため）
-- TODO: 依存関係問題を解決したら再有効化

return {
  -- Mason関連は一時的に無効化
  -- 現在はLSPエラーが発生するため
}