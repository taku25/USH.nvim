-- lua/USH/emitter.lua (新規作成)

local unl_provider = require("UNL.provider")
local unl_config = require("UNL.config")
local log = require("UNL.logging").get("USH")

local M = {}
local ULG_GENERAL_LOG_CAPABILITY = "ulg.general_log"
---
-- ushellからの出力行を指定されたemitterに送信する
-- @param lines table<string> 出力する行のリスト
-- @param meta table|nil 追加情報 (例: { is_error = true, command = "..." })
function M.emit(lines, meta)
  meta = meta or {}
  local conf = unl_config.get("USH").output
  
  if conf.emitter == "ULG" then
    -- ULGのProviderに通知を試みる
    unl_provider.notify(ULG_GENERAL_LOG_CAPABILITY, {
      lines = lines,
      meta = meta, -- エラー情報などを渡せる
    })

  elseif conf.emitter == "notify" then
    local content = table.concat(lines, "\n")
    vim.notify(content, conf.notify.level, { title = "USH" })

  elseif conf.emitter == "echo" then
    local chunks = {}
    for _, line in ipairs(lines) do
      table.insert(chunks, { line, "Normal" })
    end
    vim.api.nvim_echo(chunks, true, {})
  
  elseif conf.emitter == "none" then
    -- 何もしない
  else
    log.warn("Unknown output emitter specified: '%s'", conf.emitter)
  end
end

return M
