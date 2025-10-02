-- lua/USH/session.lua (完全版)

local emitter = require("USH.emitter")
local log = require("USH.logger")
local unl_finder = require("UNL.finder")

local M = {
  job_id = nil,
}

----------------------------------------------------------------------
-- Private Job Callbacks
----------------------------------------------------------------------

local function on_stdout(_, data)
  if data and #data > 0 and data[#data] == "" then
    table.remove(data)
  end
  if data and #data > 0 then
    emitter.emit(data)
  end
end

local function on_stderr(_, data)
  if data and #data > 0 and data[#data] == "" then
    table.remove(data)
  end
  if data and #data > 0 then
    log.get().warn("ushell stderr: %s", vim.inspect(data))
    emitter.emit(data, { is_error = true })
  end
end

local function on_exit(_, code)
  log.get().info("ushell process exited with code: %d", code)
  M.job_id = nil
  emitter.emit({ string.format("--- ushell process finished (code: %d) ---", code) })
end

----------------------------------------------------------------------
-- Public API
----------------------------------------------------------------------

function M.is_active()
  return M.job_id and M.job_id > 0
end

function M.start(opts)
  opts = opts or {}
  if M.is_active() then
    return
  end

  local project = unl_finder.project.find_project(vim.loop.cwd())
  if not project or not project.uproject then
    return vim.notify("USH Error: .uproject file not found.", vim.log.levels.ERROR)
  end

  local engine = unl_finder.engine.find_engine_root(project.uproject)
  if not engine then
    return vim.notify("USH Error: Could not find Engine root.", vim.log.levels.ERROR)
  end

  local boot_cmd_dir = engine .. "/Engine/Extras/ushell/channels/flow/nt"

  local command
  local command_args
  local job_opts = {
    -- cwd (カレントディレクトリ) は必ずプロジェクトのルートに設定
    cwd = project.root,
    on_stdout = on_stdout,
    on_stderr = on_stderr,
    on_exit = on_exit,
  }

  if vim.fn.has("win32") == 1 then
    local ushell_script_path = (boot_cmd_dir .. "/boot.bat"):gsub("/", "\\")
    if vim.fn.filereadable(ushell_script_path) == 0 then
      return vim.notify("USH Error: ushell.bat not found at " .. ushell_script_path, vim.log.levels.ERROR)
    end

    command = "cmd.exe"
    -- ドライブ変更などの余計なコマンドを一切含まない、最もシンプルな形
    command_args = { "/d", "/k", ushell_script_path }

  else -- Linux, macOS
    local ushell_script_path = boot_cmd_dir .. "/boot.sh"
    if vim.fn.filereadable(ushell_script_path) == 0 then
      return vim.notify("USH Error: ushell.sh not found!", vim.log.levels.ERROR)
    end
    command = ushell_script_path
    command_args = {}
  end

  local full_command = vim.list_extend({ command }, command_args)
  M.job_id = vim.fn.jobstart(full_command, job_opts)

  if not M.is_active() then
    log.get().error("Failed to start job. job_id is invalid: %s", tostring(M.job_id))
    return vim.notify("USH Error: Failed to start the ushell process.", vim.log.levels.ERROR)
  end

  emitter.emit({ string.format("--- ushell session starting (Job ID: %d)... ---", M.job_id) })
  log.get().info("ushell session process initiated successfully.")
end

function M.stop()
  if not M.is_active() then
    return
  end
  vim.fn.jobstop(M.job_id)
  log.get().info("Stopping ushell session (Job ID: %d)...", M.job_id)
end

function M.send_command(command_str)
  if not M.is_active() then
    return
  end

  emitter.emit({ string.format("--- Executing in ushell: %s ---", command_str) })

  -- ushellの起動処理を待つための、シンプルな遅延実行
  vim.defer_fn(function()
    if M.is_active() then -- 遅延実行時にもセッションが有効か再チェック
      log.get().debug("Sending command after delay: %s", command_str)
      vim.api.nvim_chan_send(M.job_id, command_str .. "\n")
    else
      log.get().warn("Session ended before delayed command could be sent.")
    end
  end, 500) -- 0.5秒の遅延
end

return M
