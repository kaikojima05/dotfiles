-- 全プラグイン動作検証システム
local M = {}

-- プラグイン検証テストスイート
M.validation_tests = {
    lspconfig = function()
        local ok, lspconfig = pcall(require, "lspconfig")
        if not ok then
            return false, "lspconfig パッケージの読み込みに失敗"
        end
        
        local util_ok, util = pcall(require, "lspconfig.util")
        if not util_ok then
            return false, "lspconfig.util の読み込みに失敗"
        end
        
        -- root_pattern関数のテスト
        local pattern_ok, pattern_fn = pcall(util.root_pattern, ".git")
        if not pattern_ok then
            return false, "root_pattern 関数の実行に失敗"
        end
        
        return true, "lspconfig 正常動作"
    end,
    
    lazy = function()
        local ok, lazy = pcall(require, "lazy")
        if not ok then
            return false, "lazy パッケージの読み込みに失敗"
        end
        
        local plugins = lazy.plugins()
        if not plugins or vim.tbl_count(plugins) == 0 then
            return false, "プラグインリストの取得に失敗"
        end
        
        return true, string.format("lazy 正常動作 (%d プラグイン)", vim.tbl_count(plugins))
    end,
    
    telescope = function()
        local ok, telescope = pcall(require, "telescope")
        if not ok then
            return false, "telescope パッケージの読み込みに失敗"
        end
        
        local builtin_ok, builtin = pcall(require, "telescope.builtin")
        if not builtin_ok then
            return false, "telescope.builtin の読み込みに失敗"
        end
        
        return true, "telescope 正常動作"
    end,
    
    cmp = function()
        local ok, cmp = pcall(require, "cmp")
        if not ok then
            return false, "cmp パッケージの読み込みに失敗"
        end
        
        local config = cmp.get_config()
        if not config then
            return false, "cmp 設定の取得に失敗"
        end
        
        return true, "cmp 正常動作"
    end,
    
    treesitter = function()
        local ok, treesitter = pcall(require, "nvim-treesitter")
        if not ok then
            return false, "nvim-treesitter パッケージの読み込みに失敗"
        end
        
        local configs_ok, configs = pcall(require, "nvim-treesitter.configs")
        if not configs_ok then
            return false, "treesitter configs の読み込みに失敗"
        end
        
        return true, "treesitter 正常動作"
    end,
    
    mason = function()
        local ok, mason = pcall(require, "mason")
        if not ok then
            return false, "mason パッケージの読み込みに失敗"
        end
        
        local lsp_ok, mason_lsp = pcall(require, "mason-lspconfig")
        if not lsp_ok then
            return false, "mason-lspconfig の読み込みに失敗"
        end
        
        return true, "mason 正常動作"
    end
}

-- 全プラグインの検証実行
function M.validate_all_plugins()
    local results = {
        passed = {},
        failed = {},
        total = 0,
        success_rate = 0
    }
    
    for name, test_fn in pairs(M.validation_tests) do
        results.total = results.total + 1
        local success, message = test_fn()
        
        if success then
            results.passed[name] = message
        else
            results.failed[name] = message
        end
    end
    
    results.success_rate = (vim.tbl_count(results.passed) / results.total) * 100
    
    return results
end

-- 詳細な動作検証レポート
function M.generate_validation_report()
    local report = {
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        validation_results = M.validate_all_plugins(),
        lsp_servers = {},
        performance_metrics = {}
    }
    
    -- LSPサーバーの状態確認
    local clients = vim.lsp.get_active_clients()
    for _, client in ipairs(clients) do
        report.lsp_servers[client.name] = {
            id = client.id,
            root_dir = client.config.root_dir,
            filetypes = client.config.filetypes,
            initialized = client.initialized
        }
    end
    
    -- パフォーマンスメトリクス（簡易版）
    report.performance_metrics = {
        startup_time = vim.fn.reltimestr(vim.fn.reltime(vim.g.start_time or vim.fn.reltime())),
        plugin_count = vim.tbl_count(require("lazy").plugins()),
        lsp_client_count = #clients,
        memory_usage = collectgarbage("count") .. " KB"
    }
    
    return report
end

-- 検証結果の表示
function M.display_validation_results()
    local results = M.validate_all_plugins()
    
    vim.schedule(function()
        print("=== プラグイン動作検証結果 ===")
        print(string.format("成功率: %.1f%% (%d/%d)", 
            results.success_rate, 
            vim.tbl_count(results.passed), 
            results.total))
        
        if vim.tbl_count(results.passed) > 0 then
            print("\n✅ 正常動作:")
            for name, message in pairs(results.passed) do
                print(string.format("  %s: %s", name, message))
            end
        end
        
        if vim.tbl_count(results.failed) > 0 then
            print("\n❌ 問題のあるプラグイン:")
            for name, message in pairs(results.failed) do
                print(string.format("  %s: %s", name, message))
            end
        end
        
        print("\n=== 検証完了 ===")
    end)
    
    return results
end

-- 自動修復機能
function M.attempt_auto_repair()
    local results = M.validate_all_plugins()
    local repairs = {}
    
    for plugin_name, error_msg in pairs(results.failed) do
        if plugin_name == "lspconfig" then
            -- lspconfig の自動修復
            vim.schedule(function()
                vim.cmd("Lazy reload nvim-lspconfig")
                repairs[#repairs + 1] = "lspconfig reloaded"
            end)
        elseif plugin_name == "mason" then
            -- mason の自動修復
            vim.schedule(function()
                vim.cmd("MasonUpdate")
                repairs[#repairs + 1] = "mason updated"
            end)
        elseif plugin_name == "lazy" then
            -- lazy の自動修復
            vim.schedule(function()
                vim.cmd("Lazy sync")
                repairs[#repairs + 1] = "lazy synced"
            end)
        end
    end
    
    return repairs
end

return M