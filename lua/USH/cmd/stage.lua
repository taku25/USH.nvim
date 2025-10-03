-- lua/USH/cmd/stage.lua (新規作成)

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

  -- bang付きの場合 (`:USH stage!`) はピッカーを表示
  if opts.has_bang then
    local presets = ush_conf.stage_presets
    if not presets or #presets == 0 then
      return vim.notify("No stage presets defined in config.", vim.log.levels.WARN)
    end

    unl_picker.pick({
      items = presets,
      title = " Select Stage Preset",
      conf = ush_conf,
      preview_enabled = false,
      format = function(entry) return entry.name end,
      on_submit = function(selected)
        if selected then
          local stage_cmd = ".stage " .. selected.args
          session.send_command(stage_cmd)
        end
      end,
    })
  else
    -- 引数がある場合は、それを直接ushellコマンドとして実行
    if #opts.args > 0 then
      local stage_cmd = ".stage " .. table.concat(opts.args, " ")
      session.send_command(stage_cmd)
    else
      -- 引数がない場合はヘルプを表示するか、何もしない
      log.warn("Please specify stage arguments. e.g., :USH stage game win64")
      vim.notify("Please specify stage arguments.", vim.log.levels.INFO)
    end
  end
end

return M
