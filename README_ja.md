# Unreal Shell 💓 Neovim

<table>
<tr>
 <td><div align=center><img width="100%" alt="image" src="https://github.com/user-attachments/assets/d18ba4cb-2da1-4ac4-8b9f-8c150cdccf8f" /></div></td>
</tr>
</table>

`USH.nvim` は、Unreal Engine の対話的シェル `ushell` と連携し、`.build`, `.cook`, `.run` といった様々なコマンドを、Neovimから直接、永続的な非同期セッション内で実行するためのプラグインです。



[English](https://www.google.com/search?q=./README.md) | [日本語](https://www.google.com/search?q=./README_ja.md)

-----

## ✨ 機能 (Features)

  * **永続的な非同期セッション**: Neovimの標準機能（`vim.fn.jobstart`）のみを使用し、`ushell` をバックグラウンドで起動・管理します。一度起動すれば、Neovimを閉じるまでセッションが維持されます。
  * **柔軟な設定システム**:
      * `UNL.nvim` の強力な設定システムをベースにしており、グローバル設定に加え、プロジェクトルートの `.unlrc.json` ファイルによるプロジェクト固有設定の上書きが可能です。
  * **設定可能な出力**: `ushell` からのリアルタイムな出力を、[`ULG.nvim`](https://www.google.com/search?q=%5Bhttps://github.com/taku25/ULG.nvim%5D\(https://github.com/taku25/ULG.nvim\)) のようなログビューアーや、`vim.notify`, `vim.echo` など、好みの場所にリダイレクトできます。
  * **統一されたUIピッカー**: [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) や [fzf-lua](https://github.com/ibhagwan/fzf-lua) といった人気のUIプラグインを自動で認識し、コマンドのプリセット選択を快適に行えます。(**オプション**)
  * **`UEP.nvim` / `UBT.nvim` との連携**: もし `UBT.nvim` がインストールされていれば、そのビルドプリセット設定を自動で読み込んで利用します。また、`UEP.nvim` があれば、モジュール一覧をピッカーで表示できます。`USH.nvim` 単体でも動作するよう、フォールバック機能も内蔵しています。

<table>
<tr>
 <td><div align=center><img width="100%" alt="image" src="https://github.com/user-attachments/assets/a90aabc2-41f0-464f-94e5-d679adb44bf6" /></div></td>
</tr>
</table>

## 🔧 必要要件 (Requirements)

  * Neovim v0.11.3 以上
  * **[UNL.nvim](https://github.com/taku25/UNL.nvim)** (**必須**)
  * [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (**オプション**)
  * [fzf-lua](https://github.com/ibhagwan/fzf-lua) (**オプション**)
  * [`ULG.nvim`](https://www.google.com/search?q=%5Bhttps://github.com/taku25/ULG.nvim%5D\(https://github.com/taku25/ULG.nvim\)) (オプション、`emitter` のデフォルト出力先)
  * Unreal Engine がインストールされており、`ushell` が利用可能な環境
  * Windows (現在、他のOSでの動作確認は行っていません)

## 🚀 インストール (Installation)

お使いのプラグインマネージャーでインストールしてください。

### [lazy.nvim](https://github.com/folke/lazy.nvim)

`UNL.nvim` が必須の依存関係です。`lazy.nvim` はこれを自動で解決します。

```lua
-- lua/plugins/ush.lua

return {
  'taku25/USH.nvim',
  dependencies = { 'taku25/UNL.nvim' },
  
  opts = {
    -- ここに設定を記述します (詳細は後述)
  }
}
```

## ⚙️ 設定 (Configuration)

`setup()` 関数（または `lazy.nvim` の `opts`）にテーブルを渡すことで、プラグインの挙動をカスタマイズできます。
以下は、すべてのオプションと、そのデフォルト値です。

```lua
-- init.lua や ush.lua の opts = { ... } の中身

{
  -- `UBT.nvim` の設定がない場合のフォールバック用ビルドプリセット
  presets = {
    { name = "Win64DevelopWithEditor", Platform = "Win64", IsEditor = true, Configuration = "Development" },
    { name = "Win64DebugGameWithEditor", Platform = "Win64", IsEditor = true, Configuration = "DebugGame" },
    { name = "Win64Develop", Platform = "Win64", IsEditor = false, Configuration = "Development" },
    { name = "Win64DebugGame", Platform = "Win64", IsEditor = false, Configuration = "DebugGame" },
    { name = "Win64Shipping", Platform = "Win64", IsEditor = false, Configuration = "Shipping" },
  },

  -- エンジンの自動検出が失敗する場合に、手動でパスを指定します
  -- 例: "C:/Program Files/Epic Games/UE_5.4"
  engine_path = nil,

  -- :USH build でターゲット名を省略した際のデフォルト
  preset_target = "Win64DevelopWithEditor",

  -- Cook command presets
  cook_presets = {
    { name = "Cook Game (Win64)", platform = "win64", type = "game", options = "" },
    { name = "Cook Game OnTheFly (Win64)", platform = "win64", type = "game", options = "--onthefly" },
  },

  -- Run command presets
  run_presets = {
    { name = "Run Editor", mode = "editor", args = "" },
    { name = "Run Game", mode = "game", args = "" },
    { name = "Run Game (Debug)", mode = "game", args = "--attach" },
    { name = "Run Program (UnrealInsights)", mode = "program", args = "UnrealInsights" },
  },

  -- Staging command presets
  stage_presets = {
    { name = "Stage Game (Win64)", args = "game win64" },
    { name = "Stage Game (PS4, Dev, Full)", args = "game ps4 development pak --build --cook" },
  },

  -- UAT command presets
  uat_presets = {
    {
      name = "Build, Cook, and Archive (Win64)",
      command_string = "BuildAndCook -platform=Win64 -clientconfig=Development -cook -allmaps -build -stage -pak -archive",
    },
  },

  -- P4 subcommands for the picker
  p4_subcommands = {
    { name = "sync", desc = "Syncs the current project and engine.", arg_required = false },
    { name = "clean", desc = "Cleans intermediate files from the branch.", arg_required = false },
    { name = "cherrypick", desc = "Integrates or reverts a changelist.", arg_required = true, arg_prompt = "Enter Changelist number(s):" },
  },

  -- ushellからの出力先を指定
  output = {
    emitter = "ULG", -- "ULG", "notify", "echo", "none"
    notify = {
      level = vim.log.levels.INFO,
    },
  },

  -- ===== UIとロギング設定 (UNL.nvimから継承) =====
  
  ui = {
    picker = {
      mode = "auto",
      prefer = { "telescope", "fzf_lua", "native" },
    },
  },

  logging = {
    level = "info",
    echo = { level = "warn" },
    notify = { level = "error", prefix = "[USH]" },
    file = { enable = true, filename = "ush.log" },
  },
}
```

### プロジェクト固有の設定

プロジェクトのルートディレクトリに `.unlrc.json` を作成することで、そのプロジェクト固有の設定（例えばデフォルトのビルドターゲット）を定義できます。

例: `.unlrc.json`

```json
{
  "preset_target": "Win64Shipping"
}
```

## ⚡ 使い方 (Usage)

コマンドは、Unreal Engineプロジェクトのディレクトリ内で実行してください。

| コマンド                  | 説明                                                                     |
| ------------------------- | ------------------------------------------------------------------------ |
| `:USH start_session`      | `ushell`セッションをバックグラウンドで開始します。                       |
| `:USH stop_session`       | 現在の`ushell`セッションを停止します。                                   |
| `:USH build[!] ...`       | プロジェクトをビルドします。[\!]付きでUIピッカーを起動します。             |
| `:USH cook[!] ...`        | プロジェクトをクックします。[\!]付きでプリセットピッカーを起動します。     |
| `:USH run[!] ...`         | プロジェクトやエディタを実行します。[\!]付きでプリセットピッカーを起動します。 |
| `:USH stage[!] ...`       | ステージングを実行します。[\!]付きでプリセットピッカーを起動します。         |
| `:USH uat[!] ...`         | Unreal Automation Toolを実行します。[\!]付きでプリセットピッカーを起動します。 |
| `:USH sln[!] [generate]`  | ソリューションファイルを操作します。[generate]のみサポート。             |
| `:USH p4[!] ...`          | Perforceコマンドを実行します。[\!]付きでサブコマンドピッカーを起動します。 |
| `:USH direct ...`         | `'...'`部分のコマンドを`ushell`に直接送信します。                          |

### 💓 UIピッカー連携 (Telescope / fzf-lua)

`:USH build!`, `:USH cook!`, `:USH run!` のように `bang` 版 (`!`) を実行することで、設定に応じたUIピッカーが起動し、プリセットやサブコマンドを簡単に選択できます。

## 🤖 API & 自動化 (Automation Examples)

`USH.nvim` は、Lua APIを提供しているため、`autocmd`と組み合わせることで、開発ワークフローを効率化できます。

### 📂 プロジェクトに入ったら自動でセッションを開始

Unreal Engineのプロジェクトディレクトリに `cd` した際に、自動で `:USH start_session` を実行します。

```lua
-- init.lua or any setup file
local ush_auto_start_group = vim.api.nvim_create_augroup("USH_AutoStartSession", { clear = true })
vim.api.nvim_create_autocmd("DirChanged", {
  group = ush_auto_start_group,
  pattern = "*",
  callback = function()
    -- UNL.nvimのfinderで.uprojectファイルを探す
    local finder = require("UNL.finder")
    if not finder.project.find_project(vim.fn.getcwd()) then
      return
    end

    -- セッションがまだアクティブでなければ開始
    local session = require("USH.session")
    if not session.is_active() then
      vim.schedule(function()
        require("USH.api").start_session()
      end)
    end
  end,
})
```

## その他

Unreal Engine 関連プラグイン:

* [UEP.nvim](https://github.com/taku25/UEP.nvim)
  * urpojectを解析してファイルナビゲートなどを簡単に行えるようになります
* [UBT.nvim](https://github.com/taku25/UBT.nvim)
  * BuildやGenerateClangDataBaseなどを非同期でNeovim上から使えるようになります
* [UCM.nvim](https://github.com/taku25/UCM.nvim)
  * クラスの追加や削除がNeovim上からできるようになります。
* [ULG.nvim](https://github.com/taku25/ULG.nvim)
  * UEのログやliveCoding,stat fpsなどnvim上からできるようになります
* [USH.nvim](https://github.com/taku25/USH.nvim)
  * ushellをnvimから対話的に操作できるようになります
* [neo-tree-unl](https://github.com/taku25/neo-tree-unl.nvim)
  * IDEのようなプロジェクトエクスプローラーを表示できます。
* [tree-sitter for Unreal Engine](https://github.com/taku25/tree-sitter-unreal-cpp)
  * UCLASSなどを含めてtree-sitterの構文木を使ってハイライトができます。

## 📜 ライセンス (License)

MIT License

Copyright (c) 2025 taku25

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
