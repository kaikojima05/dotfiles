-- 予防的エラー検出メカニズム
local M = {}

-- エラーパターンデータベース
M.error_patterns = {
    {
        pattern = "lspconfig%.util",
        description = "lspconfig.util モジュールの読み込みエラー",
        severity = "high",
        auto_fix = function()
            vim.schedule(function()
                vim.cmd("Lazy reload nvim-lspconfig")
                vim.notify("lspconfig を再読み込みしました", vim.log.levels.INFO)
            end)
        end
    },
    {
        pattern = "mason%-lspconfig",
        description = "Mason LSP 設定エラー",
        severity = "high",
        auto_fix = function()
            vim.schedule(function()
                vim.cmd("MasonUpdate")
                vim.notify("Mason を更新しました", vim.log.levels.INFO)
            end)
        end
    },
    {
        pattern = "Failed to run.*lua",
        description = "Lua スクリプト実行エラー",
        severity = "medium",
        auto_fix = function()
            vim.schedule(function()
                vim.cmd("Lazy reload")
                vim.notify("プラグインを再読み込みしました", vim.log.levels.INFO)
            end)
        end
    },
    {
        pattern = "treesitter.*parser",
        description = "Treesitter パーサーエラー",
        severity = "medium",
        auto_fix = function()
            vim.schedule(function()
                vim.cmd("TSUpdate")
                vim.notify("Treesitter パーサーを更新しました", vim.log.levels.INFO)
            end)
        end
    }
}

-- プロアクティブ健全性チェック
function M.proactive_health_check()
    local issues = {}
    
    -- メモリ使用量チェック
    local memory_kb = collectgarbage("count")
    if memory_kb > 50000 then -- 50MB以上
        issues[#issues + 1] = {
            type = "performance",
            severity = "medium",
            message = string.format("メモリ使用量が高めです: %.1f MB", memory_kb / 1024),
            suggestion = "不要なバッファを閉じるか、プラグインを最適化してください"
        }
    end
    
    -- プラグイン読み込み時間チェック
    local lazy_stats = require("lazy").stats()
    if lazy_stats and lazy_stats.startuptime > 100 then
        issues[#issues + 1] = {
            type = "performance",
            severity = "low",
            message = string.format("起動時間が長めです: %d ms", lazy_stats.startuptime),
            suggestion = "不要なプラグインを無効化するか、遅延読み込みを設定してください"
        }
    end
    
    -- LSP クライアント数チェック
    local lsp_clients = vim.lsp.get_active_clients()
    if #lsp_clients > 10 then
        issues[#issues + 1] = {
            type = "resource",
            severity = "medium",
            message = string.format("LSP クライアントが多すぎます: %d 個", #lsp_clients),
            suggestion = "不要な LSP サーバーを無効化してください"
        }
    end
    
    return issues
end

-- リアルタイムエラー監視
function M.setup_realtime_monitoring()
    -- Vim エラーの監視
    vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
            -- 定期的な健全性チェック（5分間隔）
            local timer = vim.loop.new_timer()
            timer:start(300000, 300000, vim.schedule_wrap(function()
                local issues = M.proactive_health_check()
                if #issues > 0 then
                    M.handle_detected_issues(issues)
                end
            end))
        end
    })
    
    -- LSP エラーの監視
    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
            local client = vim.lsp.get_client_by_id(event.data.client_id)
            if client then
                -- LSP エラーハンドラの設定
                client.handlers["window/showMessage"] = function(_, result, ctx)
                    if result.type == vim.lsp.protocol.MessageType.Error then
                        M.handle_lsp_error(result.message, client.name)
                    end
                end
            end
        end
    })
    
    -- プラグインエラーの監視
    local original_notify = vim.notify
    vim.notify = function(msg, level, opts)
        if level == vim.log.levels.ERROR then
            M.analyze_and_handle_error(msg)
        end
        return original_notify(msg, level, opts)
    end
end

-- エラーパターン分析と自動対応
function M.analyze_and_handle_error(error_msg)
    for _, pattern_info in ipairs(M.error_patterns) do
        if string.match(error_msg, pattern_info.pattern) then
            vim.schedule(function()
                vim.notify(
                    string.format("エラーパターンを検出: %s", pattern_info.description),
                    vim.log.levels.WARN
                )
                
                -- 自動修復を試行
                if pattern_info.auto_fix then
                    vim.notify("自動修復を実行中...", vim.log.levels.INFO)
                    pattern_info.auto_fix()
                end
            end)
            break
        end
    end
end

-- 検出された問題の処理
function M.handle_detected_issues(issues)
    for _, issue in ipairs(issues) do
        local level = issue.severity == "high" and vim.log.levels.ERROR or
                     issue.severity == "medium" and vim.log.levels.WARN or
                     vim.log.levels.INFO
        
        vim.schedule(function()
            vim.notify(issue.message, level)
            if issue.suggestion then
                vim.notify("提案: " .. issue.suggestion, vim.log.levels.INFO)
            end
        end)
    end
end

-- LSP 特有のエラー処理
function M.handle_lsp_error(message, client_name)
    vim.schedule(function()
        vim.notify(
            string.format("LSP エラー [%s]: %s", client_name, message),
            vim.log.levels.ERROR
        )
        
        -- 一般的な LSP エラーの自動修復
        if string.match(message, "not found") or string.match(message, "initialize") then
            vim.notify("LSP サーバーの再起動を試行中...", vim.log.levels.INFO)
            vim.cmd("LspRestart " .. client_name)
        end
    end)
end

-- 設定健全性の検証
function M.validate_configuration()
    local config_issues = {}
    
    -- 必須プラグインの存在確認
    local required_plugins = { "lazy.nvim", "nvim-lspconfig", "nvim-cmp" }
    for _, plugin in ipairs(required_plugins) do
        local ok, _ = pcall(require, plugin:gsub("%.nvim$", ""):gsub("^nvim%-", ""))
        if not ok then
            config_issues[#config_issues + 1] = {
                type = "missing_plugin",
                plugin = plugin,
                message = string.format("必須プラグイン %s が見つかりません", plugin)
            }
        end
    end
    
    -- 設定ファイルの存在確認
    local config_files = {
        vim.fn.stdpath("config") .. "/init.lua",
        vim.fn.stdpath("config") .. "/lua/config/options.lua"
    }
    
    for _, file in ipairs(config_files) do
        if vim.fn.filereadable(file) == 0 then
            config_issues[#config_issues + 1] = {
                type = "missing_config",
                file = file,
                message = string.format("設定ファイル %s が見つかりません", file)
            }
        end
    end
    
    return config_issues
end

-- 包括的な予防システムの初期化
function M.initialize_prevention_system()
    -- リアルタイム監視の開始
    M.setup_realtime_monitoring()
    
    -- 設定検証の実行
    local config_issues = M.validate_configuration()
    if #config_issues > 0 then
        vim.schedule(function()
            vim.notify("設定の問題を検出しました:", vim.log.levels.WARN)
            for _, issue in ipairs(config_issues) do
                vim.notify("- " .. issue.message, vim.log.levels.WARN)
            end
        end)
    end
    
    -- 初回健全性チェック
    vim.defer_fn(function()
        local issues = M.proactive_health_check()
        if #issues > 0 then
            M.handle_detected_issues(issues)
        else
            vim.notify("Neovim 環境は健全です ✅", vim.log.levels.INFO)
        end
    end, 2000)
end

return M