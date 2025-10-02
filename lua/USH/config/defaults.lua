local M = {
  logging = {
    level = "info",
    echo = { level = "warn" },
    notify = { level = "warn" },
    file = { enable = true, filename = "ush.log" },
  },
  
  ui = {
    picker = {
      mode = "auto",
      prefer = { "telescope", "fzf-lua", "native" },
    },
    progress = {
      mode = "auto",
      prefer = { "fidget", "generic_status", "window" },
    }
  },
  cache = { dirname = "USH" },

  presets = {
    { name = "Win64DebugGame", Platform = "Win64", IsEditor = false, Configuration = "DebugGame" },
    { name = "Win64Develop", Platform = "Win64", IsEditor = false, Configuration = "Development" },
    { name = "Win64Shipping", Platform = "Win64", IsEditor = false, Configuration = "Shipping" },
    { name = "Win64DebugGameWithEditor", Platform = "Win64", IsEditor = true, Configuration = "DebugGame" },
    { name = "Win64DevelopWithEditor", Platform = "Win64", IsEditor = true, Configuration = "Development" },
  },
  preset_target = "Win64DevelopWithEditor",
 
  output = {
    -- 出力先を指定: "ULG", "echo", "none"
    -- "ulg": ULG.nvimの汎用ログに送信 (ULGがインストールされている場合)
    -- "notify": vim.notify() で出力
    -- "echo": vim.api.nvim_echo() で出力
    -- "none": 何も出力しない
    emitter = "ULG", 
    
    -- "notify" emitter用の設定
    notify = {
      level = vim.log.levels.INFO,
    },
    
  },  
}

return M
