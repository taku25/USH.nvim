-- lua/USH/cmd/start_session.lua

local session = require("USH.session")
local M = {}

---
-- ':USH start_session' コマンドまたは api.start_session() の実体
-- @param opts table|nil セッション開始時のオプション
function M.execute(opts)
  -- 実際のプロセス起動ロジックは session モジュールに委譲する
  session.start(opts)
end

return M
