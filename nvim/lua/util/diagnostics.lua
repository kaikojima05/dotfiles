-- 革新的なNeovim診断システム
local M = {}

-- ライブ動的解析システム
function M.setup_live_diagnostics()
    local startup_log = {}
    local plugin_health = {}
    
    -- 起動時のプラグイン監視
    vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
            vim.defer_fn(function()
                M.analyze_startup_health()
            end, 1000)
        end
    })
    
    -- LSP起動監視
    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
            local client = vim.lsp.get_client_by_id(event.data.client_id)
            if client then
                startup_log[#startup_log + 1] = {
                    timestamp = os.time(),
                    event = "lsp_attach",
                    client = client.name,
                    buffer = event.buf
                }
            end
        end
    })
    
    -- プラグインエラー監視
    vim.api.nvim_create_autocmd("User", {
        pattern = "LazyLoad",
        callback = function(event)
            startup_log[#startup_log + 1] = {
                timestamp = os.time(),
                event = "plugin_load",
                plugin = event.data
            }
        end
    })
    
    return startup_log
end

-- 階層型依存関係マッピング
function M.build_dependency_graph()
    local plugins = require("lazy").plugins()
    local graph = {}
    
    for name, plugin in pairs(plugins) do
        graph[name] = {
            dependencies = plugin.dependencies or {},
            loaded = plugin._.loaded,
            errors = {},
            health_score = 100
        }
    end
    
    return graph
end

-- プラグイン健全性スコアリング
function M.calculate_health_scores()
    local scores = {}
    local plugins = require("lazy").plugins()
    
    for name, plugin in pairs(plugins) do
        local score = 100
        
        -- 起動時間ペナルティ
        if plugin._.load_time and plugin._.load_time > 50 then
            score = score - math.min(30, plugin._.load_time / 10)
        end
        
        -- エラー履歴ペナルティ
        if plugin._.error then
            score = score - 40
        end
        
        -- 依存関係の複雑さ
        local deps = plugin.dependencies or {}
        if #deps > 5 then
            score = score - (#deps - 5) * 2
        end
        
        scores[name] = math.max(0, score)
    end
    
    return scores
end

-- 自己修復メカニズム
function M.auto_repair_common_issues()
    local fixes_applied = {}
    
    -- lspconfig.util関連の修復
    local function fix_lspconfig_util()
        local ok, lspconfig = pcall(require, "lspconfig")
        if not ok then
            return false
        end
        
        local util_ok, util = pcall(require, "lspconfig.util")
        if not util_ok then
            -- 一般的な修復：パッケージの再インストール
            vim.schedule(function()
                vim.notify("lspconfig.util エラーを検出。自動修復を試行中...", vim.log.levels.WARN)
                -- Lazy.nvimでの再インストール
                require("lazy").reload({ show = false, plugins = { "nvim-lspconfig" } })
            end)
            return true
        end
        return false
    end
    
    -- Mason LSP設定の修復
    local function fix_mason_lsp()
        local ok, mason_lsp = pcall(require, "mason-lspconfig")
        if not ok then
            return false
        end
        
        -- 一般的な問題：LSPサーバーの再インストール
        local common_servers = { "lua_ls", "tsserver", "html", "cssls" }
        for _, server in ipairs(common_servers) do
            local install_ok = pcall(vim.cmd, "MasonInstall " .. server)
            if install_ok then
                fixes_applied[#fixes_applied + 1] = "reinstalled_" .. server
            end
        end
        
        return #fixes_applied > 0
    end
    
    -- 修復実行
    if fix_lspconfig_util() then
        fixes_applied[#fixes_applied + 1] = "lspconfig_util_repair"
    end
    
    if fix_mason_lsp() then
        fixes_applied[#fixes_applied + 1] = "mason_lsp_repair"
    end
    
    return fixes_applied
end

-- 起動時の健全性分析
function M.analyze_startup_health()
    local health_report = {
        overall_score = 0,
        plugin_scores = {},
        issues = {},
        recommendations = {}
    }
    
    -- プラグイン健全性スコア計算
    health_report.plugin_scores = M.calculate_health_scores()
    
    -- 全体スコア計算
    local total_score = 0
    local plugin_count = 0
    for _, score in pairs(health_report.plugin_scores) do
        total_score = total_score + score
        plugin_count = plugin_count + 1
    end
    health_report.overall_score = plugin_count > 0 and (total_score / plugin_count) or 0
    
    -- 問題の特定
    for name, score in pairs(health_report.plugin_scores) do
        if score < 70 then
            health_report.issues[#health_report.issues + 1] = {
                plugin = name,
                score = score,
                severity = score < 50 and "critical" or "warning"
            }
        end
    end
    
    -- 推奨事項の生成
    if health_report.overall_score < 80 then
        health_report.recommendations[#health_report.recommendations + 1] = 
            "全体的な健全性が低下しています。プラグインの最適化を検討してください。"
    end
    
    -- 結果の表示
    vim.schedule(function()
        vim.notify(
            string.format("Neovim健全性スコア: %.1f/100", health_report.overall_score),
            health_report.overall_score > 80 and vim.log.levels.INFO or vim.log.levels.WARN
        )
        
        if #health_report.issues > 0 then
            vim.notify("検出された問題: " .. #health_report.issues .. "件", vim.log.levels.WARN)
        end
    end)
    
    return health_report
end

-- 詳細な診断レポート生成
function M.generate_diagnostic_report()
    local report = {
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        neovim_version = vim.version(),
        startup_time = vim.fn.reltimestr(vim.fn.reltime(vim.g.start_time or vim.fn.reltime())),
        plugin_count = #require("lazy").plugins(),
        health_analysis = M.analyze_startup_health(),
        dependency_graph = M.build_dependency_graph(),
        auto_fixes = M.auto_repair_common_issues()
    }
    
    return report
end

return M