# USH.nvim

# Unreal Shell 💓 Neovim

 
<table>
<tr>
 <td><div align=center><img width="100%" alt="image" src="https://github.com/user-attachments/assets/d18ba4cb-2da1-4ac4-8b9f-8c150cdccf8f" /></div></td>
</tr>
</table>


`USH.nvim` is a plugin to interact with Unreal Engine's interactive shell, `ushell`, directly from Neovim. It allows you to run various commands like `.build`, `.cook`, and `.run` within a persistent, asynchronous session.

Check out the other plugins in the suite for enhancing Unreal Engine development: [`UEP.nvim`](https://www.google.com/search?q=%5Bhttps://github.com/taku25/UEP.nvim%5D\(https://github.com/taku25/UEP.nvim\)), [`UCM.nvim`](https://www.google.com/search?q=%5Bhttps://github.com/taku25/UCM.nvim%5D\(https://github.com/taku25/UCM.nvim\)), and [`UBT.nvim`](https://www.google.com/search?q=%5Bhttps://github.com/taku25/UBT.nvim%5D\(https://github.com/taku25/UBT.nvim\)).
Also available are [`ULG.nvim`](https://www.google.com/search?q=%5Bhttps://github.com/taku25/ULG.nvim%5D\(https://github.com/taku25/ULG.nvim\)), [`neo-tree-unl.nvim`](https://www.google.com/search?q=%5Bhttps://github.com/taku25/neo-tree-unl.nvim%5D\(https://github.com/taku25/neo-tree-unl.nvim\)), and [tree-sitter for Unreal Engine](https://github.com/taku25/tree-sitter-unreal-cpp).

[English](https://www.google.com/search?q=./README.md) | [日本語 (Japanese)](https://www.google.com/search?q=./README_ja.md)

-----

## ✨ Features

  * **Persistent Asynchronous Session**: Starts and manages a `ushell` session in the background using only Neovim's standard functionality (`vim.fn.jobstart`). Once started, the session persists until Neovim is closed.
  * **Flexible Configuration System**:
      * Based on `UNL.nvim`'s powerful configuration system, allowing project-specific settings in a `.unlrc.json` file in the project root to override global settings.
  * **Configurable Output**: Redirect real-time output from `ushell` to your preferred destination, such as a log viewer like [`ULG.nvim`](https://www.google.com/search?q=%5Bhttps://github.com/taku25/ULG.nvim%5D\(https://github.com/taku25/ULG.nvim\)), `vim.notify`, or `vim.echo`, via the `emitter` setting.
  * **Unified UI Picker**: Automatically detects popular UI plugins like [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) and [fzf-lua](https://github.com/ibhagwan/fzf-lua) to provide a seamless experience for selecting build targets. (**Optional**)
  * **`UBT.nvim` Integration**: If `UBT.nvim` is installed, its build preset configuration is automatically loaded and used. Fallback presets are also built-in, allowing `USH.nvim` to function standalone.

<table>
<tr>
 <td><div align=center><img width="100%" alt="image" src="https://github.com/user-attachments/assets/a90aabc2-41f0-464f-94e5-d679adb44bf6" /></div></td>
</tr>
</table>

## 🔧 Requirements

  * Neovim v0.11.3 or later
  * **[UNL.nvim](https://github.com/taku25/UNL.nvim)** (**Required**)
  * [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (**Optional**)
  * [fzf-lua](https://github.com/ibhagwan/fzf-lua) (**Optional**)
  * [`ULG.nvim`](https://www.google.com/search?q=%5Bhttps://github.com/taku25/ULG.nvim%5D\(https://github.com/taku25/ULG.nvim\)) (Optional, default destination for the `emitter`)
  * An Unreal Engine installation with `ushell` available.
  * Windows (currently not tested on other OSes).

## 🚀 Installation

Install using your favorite plugin manager.

### [lazy.nvim](https://github.com/folke/lazy.nvim)

`UNL.nvim` is a required dependency. `lazy.nvim` will resolve this automatically.

```lua
-- lua/plugins/ush.lua

return {
  'taku25/USH.nvim',
  dependencies = { 'taku25/UNL.nvim' },
  
  opts = {
    -- Your settings go here (see Configuration section below)
  }
}
```

## ⚙️ Configuration

You can customize the plugin's behavior by passing a table to the `setup()` function (or the `opts` table in `lazy.nvim`).
The following shows all available options with their default values.

```lua
-- Inside your init.lua or opts = { ... } in ush.lua

{
  -- Fallback build presets for when UBT.nvim's config is not available
  presets = {
    { name = "Win64DevelopWithEditor", Platform = "Win64", IsEditor = true, Configuration = "Development" },
    { name = "Win64DebugGameWithEditor", Platform = "Win64", IsEditor = true, Configuration = "DebugGame" },
    { name = "Win64Develop", Platform = "Win64", IsEditor = false, Configuration = "Development" },
    { name = "Win64DebugGame", Platform = "Win64", IsEditor = false, Configuration = "DebugGame" },
    { name = "Win64Shipping", Platform = "Win64", IsEditor = false, Configuration = "Shipping" },
  },

  -- Default target when the target name is omitted in `:USH build`
  preset_target = "Win64DevelopWithEditor",

  -- Specify the destination for output from ushell
  output = {
    emitter = "ULG", -- "ULG", "notify", "echo", "none"
    notify = {
      level = vim.log.levels.INFO,
    },
  },

  -- ===== UI and Logging settings (inherited from UNL.nvim) =====
  
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

### Project-specific Configuration

You can define project-specific settings (like the default build target) by creating a JSON file named `.unlrc.json` in your project's root directory.

Example: `.unlrc.json`

```json
{
  "preset_target": "Win64Shipping"
}
```

## ⚡ Usage

Commands should be run from within an Unreal Engine project directory.

```vim
:USH start_session  " Starts the ushell session in the background.
:USH stop_session   " Stops the current ushell session.
:USH build[!]       " Builds the project. Use [!] to launch the UI picker.
:USH direct ...     " Sends the command in '...' directly to ushell (e.g., :USH direct .cook).
```

### 💓 UI Picker Integration (Telescope / fzf-lua)

You can launch the UI picker to select a build target by running the `bang` version (`!`) of the command, e.g., `:USH build!`.

## 🤖 API & Automation (Automation Examples)

`USH.nvim` provides a Lua API, allowing you to streamline your development workflow by combining it with `autocmd`.

### 📂 Automatically Start Session on Entering a Project

Automatically runs `:USH start_session` when you `cd` into an Unreal Engine project directory.

```lua
-- init.lua or any setup file
local ush_auto_start_group = vim.api.nvim_create_augroup("USH_AutoStartSession", { clear = true })
vim.api.nvim_create_autocmd("DirChanged", {
  group = ush_auto_start_group,
  pattern = "*",
  callback = function()
    -- Find the .uproject file using UNL.nvim's finder
    local finder = require("UNL.finder")
    if not finder.project.find_project(vim.fn.getcwd()) then
      return
    end

    -- If a session is not already active, start one
    local session = require("USH.session")
    if not session.is_active() then
      vim.schedule(function()
        require("USH.api").start_session()
      end)
    end
  end,
})
```

## Others

Related Unreal Engine Plugins:

  * [UEP.nvim](https://github.com/taku25/UEP.nvim) - Unreal Engine Project Manager
  * [UCM.nvim](https://github.com/taku25/UCM.nvim) - Unreal Engine Class Manager
  * [UBT.nvim](https://github.com/taku25/UBT.nvim) - Unreal Build Tool Wrapper
  * [ULG.nvim](https://github.com/taku25/ULG.nvim) - Unreal Output Log & Trace Viewer

## 📜 License

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

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
