-- plugin/USH.lua

-- コマンド定義を簡単にするためのUNL.command.builder
local builder_ok, builder = pcall(require, "UNL.command.builder")
if not builder_ok then
  return vim.notify("USH.nvim requires UNL.nvim and its command builder.", vim.log.levels.ERROR)
end

-- USH.nvimの公開Lua API
local api = require("USH.api")

-- :USHコマンドが受け付けるサブコマンドの一覧を定義
local subcommands = {
  -------------------------------------------------------------
  -- Session Management
  -------------------------------------------------------------
  ['start_session'] = {
    handler = function(opts) api.start_session(opts) end,
    desc = "Start a new ushell session for the current project.",
  },
  ["stop_session"] = {
    handler = function() api.stop_session() end,
    desc = "Stop the current ushell session.",
  },

  -------------------------------------------------------------
  -- Rich Commands (特別なUIを持つコマンド)
  -------------------------------------------------------------
  ["build"] = {
    handler = function(opts) api.build(opts) end,
    desc = "Build a project target with a rich UI.",
    bang = true,
    args = {
      { name = "target", type = "string", optional = true }
    },
  },
  ["cook"] = {
    handler = function(opts) api.cook(opts) end,
    bang = true,
    desc = ":USH cook [platform] [type] [options]",
  },
  ["run"] = {
    handler = function(opts) api.run(opts) end,
    bang = true,
    desc = ":USH run [mode] [args...]",
    -- args テーブルを定義しないことで、可変長の引数を受け取る
  },
  ["sln"] = {
    handler = function(opts) api.sln(opts) end,
    bang = true, -- bang(!)を入力してもエラーにならないように残しておく
    desc = ":USH sln (Generates the .sln file)",
    -- 引数を取らないので args テーブルは不要
  },
  ["uat"] = {
    handler = function(opts) api.uat(opts) end,
    bang = true,
    desc = ":USH uat [UAT Command and Args...]",
    -- args テーブルを定義しないことで、可変長の引数を受け取る
  },
  ["stage"] = {
      handler = function(opts) api.stage(opts) end,
      bang = true,
      desc = ":USH stage [args...]",
      -- args テーブルを定義しないことで、可変長の引数を受け取る
  },
  ["p4"] = {
      handler = function(opts) api.p4(opts) end,
      bang = true,
      desc = ":USH p4 [subcommand] [args...]",
      -- args テーブルを定義しないことで、可変長の引数を受け取る
    },
    
  -------------------------------------------------------------
  -- Raw Command Passthrough
  -------------------------------------------------------------
  ["direct"] = {
    handler = function(opts) api.direct(opts) end,
    desc = "Execute a raw command string directly in ushell.",
    -- (builderがnargs='*'のような指定に対応していれば、それを書くのがベスト)
  },
}

-- UNL.command.builderを使って:USHコマンドを生成・登録
builder.create({
  plugin_name = "USH",
  cmd_name = "USH",
  desc = "USH: Interact with Unreal Engine's ushell.",
  
  -- :USH のみ（引数なし） or 不明なサブコマンドが呼ばれた場合のデフォルトハンドラ
  handler = function(opts)
    if #opts.fargs == 0 then
      -- ユーザーに何をすべきか案内する
      vim.notify("USH: Please specify a subcommand (e.g., start_session, build, cmd).", vim.log.levels.INFO)
    else
      -- ユーザーが打ち間違えた場合にエラーを出す
      local msg = string.format("USH: Unknown subcommand '%s'. See ':help USH' for available commands.", opts.fargs[1])
      vim.notify(msg, vim.log.levels.ERROR)
    end
  end,
  
  -- 上で定義したサブコマンドのテーブル
  subcommands = subcommands,
})
