-- lua/USH/init.lua (修正)

local unl_log = require("UNL.logging")
local config_defaults = require("USH.config.defaults") -- パス修正

local M = {}
local setup_done = false

function M.setup(user_opts)
  if setup_done then return end

  unl_log.setup("USH", config_defaults, user_opts or {})
  local log = unl_log.get("USH")
  
  if log then
    log.debug("USH.nvim setup complete.")
  end
  
  setup_done = true
end

return M
