-- lua/USH/init.lua

local unl_log = require("UNL.logging")
local config_defaults = require("USH.config.defaults")

local M = {}

local setup_done = false

function M.setup(user_opts)
  if setup_done then return end

  -- UNLのロギングシステムと設定システムを初期化
  unl_log.setup("USH", config_defaults, user_opts or {})
  local log = unl_log.get("USH")
  
  -- ここで他の初期化処理が必要であれば追加
  -- 例: require("USH.session").setup() など

  if log then
    log.debug("USH.nvim setup complete.")
  end

  setup_done = true
end

return M
