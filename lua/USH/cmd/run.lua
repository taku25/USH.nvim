-- lua/USH/cmd/run.lua (新規作成)

local session = require("USH.session")
local unl_picker = require("UNL.backend.picker")
local unl_config = require("UNL.config")
local log = require("UNL.logging").get("USH")

---
-- プリセットからushell用のrunコマンド文字列を生成する
-- @param preset table run_presetsの要素
-- @return string
local function preset_to_ushell_run_string(preset)
  local parts = { ".run" }
  if preset.mode and preset.mode ~= "" then
    table.insert(parts, preset.mode)
  end
  if preset.args and preset.args ~= "" then
    table.insert(parts, preset.args)
  end
  return table.concat(parts, " ")
end

local M = {}

function M.execute(opts)
  opts = opts or {}
  opts.args = opts.args or {}

  local ush_conf = unl_config.get("USH")
  if not ush_conf then
    return log.error("USH config not found.")
  end

  -- bang付きの場合 (`:USH run!`) はピッカーを表示
  if opts.has_bang then
    local presets = ush_conf.run_presets
    if not presets or #presets == 0 then
      return vim.notify("No run presets defined in config.", vim.log.levels.WARN)
    end

    unl_picker.pick({
      items = presets,
      title = " Select Run Preset",
      conf = ush_conf,
      preview_enabled = false,
      format = function(entry) return entry.name end,
      on_submit = function(selected)
        if selected then
          local run_cmd = preset_to_ushell_run_string(selected)
          session.send_command(run_cmd)
        end
      end,
    })
  else
    -- 引数がある場合は、それを直接ushellコマンドとして実行
    if #opts.args > 0 then
      local run_cmd = ".run " .. table.concat(opts.args, " ")
      session.send_command(run_cmd)
    else
      -- 引数がない場合はデフォルトの .run editor を実行 (最も一般的)
      session.send_command(".run editor")
    end
  end
end

return M
