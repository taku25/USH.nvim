-- lua/USH/cmd/build.lua (完全版)

local session = require("USH.session")
local unl_picker = require("UNL.backend.picker")
local unl_config = require("UNL.config")
local unl_finder = require("UNL.finder")
local log = require("UNL.logging").get("USH")
local unl_api = require("UNL.api")
----------------------------------------------------------------------
-- Private: Helper Functions
----------------------------------------------------------------------

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

  -- 元のコードでは ".build " が send_command 側で付与されていたが、
  -- 複数のビルドタイプを扱うため、ここでは純粋な引数文字列のみを返す
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


----------------------------------------------------------------------
-- Private: 各サブコマンドの実行ハンドラ
----------------------------------------------------------------------

---
-- プリセットを使用してビルドする
-- @param args table 引数 (プリセット名など)
local function execute_preset(args)
  log.debug("Executing 'preset' build.")
  local conf = get_active_config()
  if not conf then
    return vim.notify("Build presets not found.", vim.log.levels.WARN)
  end

  -- 引数でプリセット名が指定されていればそれを使う
  local target_name = args and args[1] or conf.preset_target
  if not target_name then
    return vim.notify("`preset_target` is not defined in config, and no preset name was given.", vim.log.levels.WARN)
  end

  local target_preset
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

  local build_args = preset_to_ushell_build_string(target_preset)
  if build_args then
    session.send_command(".build " .. build_args)
  end
end

---
-- 特定のターゲット (モジュール/ファイル) をビルドする
-- @param args table 引数 (モジュール名 or ファイルパス)
local function execute_target(args)
  log.debug("Executing 'target' build.")
  if not args or #args == 0 then
    return vim.notify("Please specify a module name or file path for 'build target'.", vim.log.levels.WARN)
  end
  local target_path = table.concat(args, " ")
  session.send_command(".build target " .. target_path)
end

---
-- 特定のプログラムをビルドする
-- @param args table 引数 (プログラム名)
local function execute_program(args)
  log.debug("Executing 'program' build.")
  if not args or #args == 0 then
    return vim.notify("Please specify a program name for 'build program'.", vim.log.levels.WARN)
  end
  local program_name = table.concat(args, " ")
  session.send_command(".build program " .. program_name)
end

---
-- その他 (misc) のビルドコマンドを実行する
-- @param args table 引数 (例: "clangdb")
local function execute_misc(args)
  log.debug("Executing 'misc' build.")
  if not args or #args == 0 then
    return vim.notify("Please specify a subcommand for 'build misc' (e.g., clangdb).", vim.log.levels.WARN)
  end
  local misc_cmd = table.concat(args, " ")
  session.send_command(".build misc " .. misc_cmd)
end

local function execute_current_file()
  local current_file = vim.fn.expand('%:p') -- 現在のバッファのフルパスを取得
  if not current_file or current_file == '' then
    return vim.notify("No file is currently open in the buffer.", vim.log.levels.WARN)
  end
  log.debug("Executing 'current_file' build for: %s", current_file)
  session.send_command(".build target " .. current_file)
end
---
-- UIピッカーを使ってビルドモードを選択・実行する
local function execute_with_picker()
  -- ユーザーの修正を反映: USHのコンフィグのみを直接取得
  local ush_conf = unl_config.get("USH")
  if not ush_conf then
    return vim.notify("USH config not found.", vim.log.levels.WARN)
  end

  local build_modes = {
    { name = "󰆍 Build from Preset", handler = function()
        local conf = get_active_config() -- プリセットビルドは従来通り UBT も見る
        if not conf then return vim.notify("Build presets not found.", vim.log.levels.WARN) end
        unl_picker.pick({
          items = conf.presets,
          title = " Select Build Preset",
          conf = conf,

          preview_enabled = false, -- ◀◀◀ Add this line
          format = function(entry) return entry.name end,
          on_submit = function(selected)
            if selected then
              local build_args = preset_to_ushell_build_string(selected)
              if build_args then session.send_command(".build " .. build_args) end
            end
          end,
        })
      end },
    { name = " Build Module", handler = function()
        local ok, modules = unl_api.provider.request("uep.get_project_modules")

        -- ▼▼▼【修正点】最初の戻り値 `ok` を使って成功判定を行う ▼▼▼
        if not ok or type(modules) ~= "table" or #modules == 0 then
          -- ユーザーに状況を通知
          
          -- 手動入力UIを起動
          vim.ui.input({ prompt = "Enter Module or File Path:" }, function(input)
            if input and #input > 0 then
              execute_target({ input })
            end
          end)
        else
          -- 正常にmodulesが取得できた場合はピッカーを表示
          unl_picker.pick({
            items = modules,
            title = " Select Module to Build",
            conf = ush_conf,
            preview_enabled = false,
            format = function(entry)
              return string.format("%s (%s)", entry.name, entry.category)
            end,
            on_submit = function(selected_module)
              if selected_module then
                execute_target({ selected_module.name })
              end
            end,
          })
        end
      end },
    { name = "󰗼 Build Program", handler = function()
        vim.ui.input({ prompt = "Enter Program Name (e.g., UnrealInsights):" }, function(input)
          if input and #input > 0 then execute_program({ input }) end
        end)
      end },
    { name = "󰗃 Generate Clang Database", handler = function()
        execute_misc({ "clangdb" })
      end },
    { name = " Compile Current File", handler = execute_current_file }
  }

  unl_picker.pick({
    items = build_modes,
    title = " Select Build Mode",
    conf = ush_conf, -- ◀◀◀ ユーザーの修正を反映
    preview_enabled = false, -- ◀◀◀ Add this line
    format = function(entry) return entry.name end,
    on_submit = function(selected)
      if selected and selected.handler then
        selected.handler()
      end
    end,
  })
end


----------------------------------------------------------------------
-- Public: コマンドのエントリーポイント
----------------------------------------------------------------------
local M = {}

function M.execute(opts)
  opts = opts or {}
  opts.args = opts.args or {}

  -- 1. bang付きの場合 (`:USH build!`) はマスターピッカーを表示
  if opts.has_bang then
    return execute_with_picker()
  end

  -- 2. 引数がある場合、最初の引数をサブコマンドとして解釈
  if #opts.args > 0 then
    local subcommand = opts.args[1]
    local sub_args = {}
    for i = 2, #opts.args do table.insert(sub_args, opts.args[i]) end

    if subcommand == "target" then
      return execute_target(sub_args)
    elseif subcommand == "file" or subcommand == "current" then
      return execute_current_file()
    elseif subcommand == "program" then
      return execute_program(sub_args)
    elseif subcommand == "misc" then
      return execute_misc(sub_args)
    else
      -- サブコマンドが一致しない場合、従来のプリセット名指定とみなす
      return execute_preset(opts.args)
    end
  end

  -- 3. 引数がなければ、config の preset_target を使用 (従来のデフォルト動作)
  execute_preset()
end

return M
