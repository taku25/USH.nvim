-- lua/USH/api.lua

local session = require("USH.session")
local log = require("UNL.logging").get("USH")


local M = {}

----------------------------------------------------------------------
-- Session Management
----------------------------------------------------------------------

---
-- ushellセッションを開始する。
-- 内部的に 'USH.cmd.start_session' を呼び出す。
-- @param opts table|nil セッション開始時のオプション（将来的な拡張用）
function M.start_session(opts)
  log.debug("API call: USH.api.start_session, delegating to cmd module.")
  local ok, cmd = pcall(require, "USH.cmd.start_session")
  if ok and cmd.execute then
    cmd.execute(opts)
  else
    log.error("Failed to load or execute 'USH.cmd.start_session'.")
  end
end

---
-- ushellセッションを停止する。
-- 内部的に 'USH.cmd.stop_session' を呼び出す。
function M.stop_session()
  log.debug("API call: USH.api.stop_session, delegating to cmd module.")
  local ok, cmd = pcall(require, "USH.cmd.stop_session")
  if ok and cmd.execute then
    cmd.execute()
  else
    log.error("Failed to load or execute 'USH.cmd.stop_session'.")
  end
end


----------------------------------------------------------------------
-- Command Execution
----------------------------------------------------------------------

---
-- 'build' コマンドをリッチハンドラ経由で実行する。
-- @param args table|nil ビルドターゲットなどの引数
function M.build(opts)
  local cmd_build = require("USH.cmd.build")
  if not session.is_active() then
    return vim.notify("USH Error: Session not started. Run ':USH start_session' first.", vim.log.levels.ERROR)
  end
  cmd_build.execute(opts)
end

function M.cook(opts)
  local cmd_cook = require("USH.cmd.cook")
  if not session.is_active() then
    return vim.notify("USH Error: Session not started. Run ':USH start_session' first.", vim.log.levels.ERROR)
  end
  cmd_cook.execute(opts or {})
end

function M.run(opts)
  local cmd_run = require("USH.cmd.run")
  if not session.is_active() then
    return vim.notify("USH Error: Session not started. Run ':USH start_session' first.", vim.log.levels.ERROR)
  end
  cmd_run.execute(opts or {})
end

function M.sln(opts)
  local cmd = require("USH.cmd.sln")
  if not session.is_active() then
    return vim.notify("USH Error: Session not started. Run ':USH start_session' first.", vim.log.levels.ERROR)
  end
  cmd.execute(opts or {})
end

function M.uat(opts)
  local cmd = require("USH.cmd.uat")
  if not session.is_active() then
    return vim.notify("USH Error: Session not started. Run ':USH start_session' first.", vim.log.levels.ERROR)
  end
  cmd.execute(opts or {})
end

function M.stage(opts)
  local cmd = require("USH.cmd.stage")
  if not session.is_active() then
    return vim.notify("USH Error: Session not started. Run ':USH start_session' first.", vim.log.levels.ERROR)
  end
  cmd.execute(opts or {})
end

function M.p4(opts)
  local cmd = require("USH.cmd.p4")
  if not session.is_active() then
    return vim.notify("USH Error: Session not started. Run ':USH start_session' first.", vim.log.levels.ERROR)
  end
  cmd.execute(opts or {})
end
function M.direct(opts)
  local cmd_direct = require("USH.cmd.direct")
  if not session.is_active() then
    return vim.notify("USH Error: Session not started. Run ':USH start_session' first.", vim.log.levels.ERROR)
  end
  cmd_direct.execute(opts or {})
end


return M
