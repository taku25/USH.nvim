-- lua/USH/cmd/cook.lua (修正版)

local session = require("USH.session")
local unl_picker = require("UNL.backend.picker")
local unl_config = require("UNL.config")
local log = require("UNL.logging").get("USH")

---
-- プリセットからushell用のクックコマンド文字列を生成する
-- @param preset table cook_presetsの要素
-- @return string
local function preset_to_ushell_cook_string(preset)
  local parts = { ".cook" }
  
  -- ▼▼▼【修正点】引数の順序を [type] [platform] [options] に変更 ▼▼▼
  -- 1. type (game, client, server, etc.)
  if preset.type and preset.type ~= "" then
    table.insert(parts, preset.type)
  end
  -- 2. platform (win64, linux, android, etc.)
  if preset.platform and preset.platform ~= "" then
    table.insert(parts, preset.platform)
  end
  -- 3. options (--onthefly, etc.)
  if preset.options and preset.options ~= "" then
    table.insert(parts, preset.options)
  end
  -- ▲▲▲ ここまで ▲▲▲

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

  -- bang付きの場合 (`:USH cook!`) はピッカーを表示
  if opts.has_bang then
    local presets = ush_conf.cook_presets
    if not presets or #presets == 0 then
      return vim.notify("No cook presets defined in config.", vim.log.levels.WARN)
    end

    unl_picker.pick({
      items = presets,
      title = " Select Cook Preset",
      conf = ush_conf,
      preview_enabled = false,
      format = function(entry) return entry.name end,
      on_submit = function(selected)
        if selected then
          local cook_cmd = preset_to_ushell_cook_string(selected)
          session.send_command(cook_cmd)
        end
      end,
    })
  else
    -- 引数がある場合は、それを直接ushellコマンドとして実行
    if #opts.args > 0 then
      local cook_cmd = ".cook " .. table.concat(opts.args, " ")
      session.send_command(cook_cmd)
    else
      -- 引数がない場合はデフォルトの .cook を実行
      session.send_command(".cook")
    end
  end
end

return M
