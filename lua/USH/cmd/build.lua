local session = require("USH.session")
local unl_picker = require("UNL.backend.picker")
local unl_config = require("UNL.config")
local unl_finder = require("UNL.finder")
local log = require("UNL.logging").get("USH")

local M = {}

-- 現在のプロジェクト名を取得するヘルパー関数
local function get_project_name()
  local project = unl_finder.project.find_project(vim.loop.cwd())
  if project and project.uproject then
    return vim.fn.fnamemodify(project.uproject, ":t:r")
  end
  return nil
end

---
-- UBT.nvimのプリセットからushell用のビルド文字列を生成する
-- 'target' サブコマンドを使用する
-- @param preset table UBT.nvimのプリセット
-- @return string|nil
local function preset_to_ushell_build_string(preset)
  local project_name = get_project_name()
  if not project_name then
    log.error("Could not determine the current project name.")
    return nil
  end

  local target_name = project_name
  if preset.IsEditor then
    target_name = target_name .. "Editor"
  end

  return string.format("target %s %s %s", target_name, preset.Platform, preset.Configuration)
end


-- UBT.nvim または USH.nvim から、利用可能なプリセットとコンフィグ全体を取得する
local function get_active_config()
  local ubt_conf = unl_config.get("UBT")
  if ubt_conf and ubt_conf.presets and #ubt_conf.presets > 0 then
    log.debug("Using presets from UBT.nvim config.")
    return ubt_conf
  end

  log.debug("UBT.nvim presets not found. Falling back to USH.nvim config.")
  local ush_conf = unl_config.get("USH")
  if ush_conf and ush_conf.presets and #ush_conf.presets > 0 then
    return ush_conf
  end

  return nil
end


---
-- ':USH build' コマンドの実体
-- @param opts table builderから渡される引数テーブル
function M.execute(opts)
  opts = opts or {}
  opts.args = opts.args or {}

  -- 1. bang付きの場合 (`:USH build!`) はピッカーを表示
  if opts.has_bang then
    local conf = get_active_config()
    if not conf then
      return vim.notify("Build presets not found.", vim.log.levels.WARN)
    end
    
    unl_picker.pick({
      items = conf.presets,
      title = "  USH Build",
      conf = conf,
      format = function(entry) return entry.name end,
      preview_enabled = false, 
      on_submit = function(selected)
        if not selected then return end
        local build_str = preset_to_ushell_build_string(selected)
        if build_str then
          -- ★★★ 変更点: 先頭に '.' を追加 ★★★
          session.send_command(".build " .. build_str)
        end
      end,
    })
    return
  end

  -- 2. bang無しの場合 (`:USH build` または `:USH build <args>`)
  
  -- 2a. もし引数が直接指定されていれば、それを最優先で実行
  if #opts.args > 0 then
    log.debug("Build command with direct arguments.")
    -- ★★★ 変更点: 先頭に '.' を追加 ★★★
    session.send_command(".build " .. table.concat(opts.args, " "))
    return
  end

  -- 2b. 引数がなければ、config の preset_target を使用
  log.debug("Build command with preset_target.")
  local conf = get_active_config()
  if not conf then
    return vim.notify("Build presets not found.", vim.log.levels.WARN)
  end

  local target_name = conf.preset_target
  if not target_name then
    return vim.notify("`preset_target` is not defined in config.", vim.log.levels.WARN)
  end

  local target_preset = nil
  for _, p in ipairs(conf.presets) do
    if p.name == target_name then
      target_preset = p
      break
    end
  end

  if not target_preset then
    local msg = string.format("Preset named '%s' not found in presets list.", target_name)
    return vim.notify(msg, vim.log.levels.ERROR)
  end
  
  local build_str = preset_to_ushell_build_string(target_preset)
  if build_str then
    -- ★★★ 変更点: 先頭に '.' を追加 ★★★
    session.send_command(".build " .. build_str)
  end
end

return M
