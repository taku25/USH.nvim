-- lua/USH/cmd/sln.lua (generate専用の簡略版)

local session = require("USH.session")
local log = require("UNL.logging").get("USH")

local M = {}

function M.execute(opts)
  -- このコマンドは引数やbang(!)を無視し、常に generate を実行する
  log.debug("Executing 'sln generate'.")
  session.send_command(".sln generate")
  
  -- ユーザーにコマンドが送信されたことをフィードバックする
  -- vim.notify("Sent command: .sln generate", vim.log.levels.INFO)
end

return M
