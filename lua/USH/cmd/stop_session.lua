-- lua/USH/cmd/end_session.lua

local session = require("USH.session")
local M = {}

---
-- ':USH end_session' コマンドまたは api.end_session() の実体
function M.execute()
  session.stop()
end

return M
