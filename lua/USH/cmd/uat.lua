-- lua/USH/cmd/uat.lua (新規作成)

local session = require("USH.session")
local unl_picker = require("UNL.backend.picker")
local unl_config = require("UNL.config")
local log = require("UNL.logging").get("USH")

local M = {}

function M.execute(opts)
  opts = opts or {}
  opts.args = opts.args or {}

  local ush_conf = unl_config.get("USH")
  if not ush_conf then
    return log.error("USH config not found.")
  end

  -- bang付きの場合 (`:USH uat!`) はピッカーを表示
  if opts.has_bang then
    local presets = ush_conf.uat_presets
    if not presets or #presets == 0 then
      return vim.notify("No UAT presets defined in config.", vim.log.levels.WARN)
    end

    unl_picker.pick({
      items = presets,
      title = " Select UAT Preset",
      conf = ush_conf,
      preview_enabled = false,
      format = function(entry) return entry.name end,
      on_submit = function(selected)
        if selected then
          -- プリセットからコマンド文字列を取得して実行
          local uat_cmd = ".uat " .. selected.command_string
          session.send_command(uat_cmd)
        end
      end,
    })
  else
    -- 引数がある場合は、それを直接ushellコマンドとして実行
    if #opts.args > 0 then
      local uat_cmd = ".uat " .. table.concat(opts.args, " ")
      session.send_command(uat_cmd)
    else
      -- 引数がない場合はヘルプを表示するか、何もしない
      log.warn("Please specify a UAT command. e.g., :USH uat BuildAndCook ...")
      vim.notify("Please specify a UAT command.", vim.log.levels.INFO)
    end
  end
end

return M
