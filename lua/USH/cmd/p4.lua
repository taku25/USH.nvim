-- lua/USH/cmd/p4.lua (新規作成)

local session = require("USH.session")
local unl_picker = require("UNL.backend.picker")
local unl_config = require("UNL.config")
local log = require("UNL.logging").get("USH")

local M = {}

function M.execute(opts)
  opts = opts or {}
  opts.args = opts.args or {}

  -- bang付き、または引数なしの場合はピッカーを表示
  if opts.has_bang or #opts.args == 0 then
    local ush_conf = unl_config.get("USH")
    if not ush_conf then return log.error("USH config not found.") end

    local subcommands = ush_conf.p4_subcommands
    if not subcommands or #subcommands == 0 then
      return vim.notify("No p4 subcommands defined in config.", vim.log.levels.WARN)
    end

    unl_picker.pick({
      items = subcommands,
      title = " Select Perforce Subcommand",
      conf = ush_conf,
      preview_enabled = false,
      format = function(entry) return string.format("%-15s (%s)", entry.name, entry.desc) end,
      on_submit = function(selected)
        if not selected then return end

        -- STEP 2-A: 選択されたコマンドが引数を必要とするかチェック
        if selected.arg_required then
          -- 引数が必要なら、vim.ui.inputでユーザーに入力を促す
          vim.ui.input({ prompt = selected.arg_prompt or "Enter argument:" }, function(input)
            if input and #input > 0 then
              local p4_cmd = string.format(".p4 %s %s", selected.name, input)
              session.send_command(p4_cmd)
            end
          end)
        else
          -- 引数が不要なら、そのままコマンドを送信
          local p4_cmd = ".p4 " .. selected.name
          session.send_command(p4_cmd)
        end
      end,
    })
  else
    -- 引数がある場合は、それを直接ushellコマンドとして実行
    local p4_cmd = ".p4 " .. table.concat(opts.args, " ")
    session.send_command(p4_cmd)
  end
end

return M
