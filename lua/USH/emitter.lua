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
  
  -- エミッターの決定
  local emitter_type = conf.emitter
  
  -- ULGが指定されているが、プロバイダーが存在しない場合は notify にフォールバック
  if emitter_type == "ULG" then
    local providers = require("UNL.provider.registry").get_all(ULG_GENERAL_LOG_CAPABILITY)
    if #providers == 0 then
      log.warn_once("ULG provider not found. Falling back to 'notify'.")
      emitter_type = "notify"
    end
  end

  if emitter_type == "ULG" then
    -- ULGのProviderに通知
    unl_provider.notify(ULG_GENERAL_LOG_CAPABILITY, {
      lines = lines,
      meta = meta, 
      ensure_window = true, -- ウィンドウを開くように要求（ULG側が対応していれば）
    })

  elseif emitter_type == "notify" then
    local content = table.concat(lines, "\n")
    vim.notify(content, conf.notify.level, { title = "USH" })

  elseif emitter_type == "echo" then
    local chunks = {}
    for _, line in ipairs(lines) do
      table.insert(chunks, { line, "Normal" })
    end
    vim.api.nvim_echo(chunks, true, {})
  
  elseif emitter_type == "none" then
    -- 何もしない
  else
    log.warn("Unknown output emitter specified: '%s'", emitter_type)
  end
end

return M
