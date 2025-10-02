-- 呼び出すモジュールを 'USH.api' から 'USH.session' に変更
local session = require("USH.session")
-- ログ出力のために unl_provider も require する
local unl_provider = require("UNL.provider")

local M = {}

---
-- ':USH direct ...' コマンドの実体
-- @param opts table handlerから渡される引数テーブル
function M.execute(opts)
  opts = opts or {}
  
local log = require("UNL.logging").get("USH")
  if not opts.args or #opts.args == 0 then
    log.warn("':USH direct' was called with no arguments.")
    return vim.notify("Please specify a command to run. e.g., ':USH direct p4 help'", vim.log.levels.WARN)
  end

  local command_str = table.concat(opts.args, " ")
  
  -- sessionモジュールの関数を直接呼び出す
  session.send_command(command_str)
end

return M
