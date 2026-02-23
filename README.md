# bufdel.nvim

bufdel.nvim is a neovim plugin that helps you delete buffers without changing windows layout.

[![GitHub License](https://img.shields.io/github/license/wsdjeg/bufdel.nvim)](LICENSE)
[![GitHub Issues or Pull Requests](https://img.shields.io/github/issues/wsdjeg/bufdel.nvim)](https://github.com/wsdjeg/bufdel.nvim/issues)
[![GitHub commit activity](https://img.shields.io/github/commit-activity/m/wsdjeg/bufdel.nvim)](https://github.com/wsdjeg/bufdel.nvim/commits/master/)
[![GitHub Release](https://img.shields.io/github/v/release/wsdjeg/bufdel.nvim)](https://github.com/wsdjeg/bufdel.nvim/releases)
[![luarocks](https://img.shields.io/luarocks/v/wsdjeg/bufdel.nvim)](https://luarocks.org/modules/wsdjeg/bufdel.nvim)

<!-- vim-markdown-toc GFM -->

- [Requirements](#requirements)
- [Installation](#installation)
    - [Using nvim-plug](#using-nvim-plug)
    - [Using lazy.nvim](#using-lazynvim)
    - [Using packer.nvim](#using-packernvim)
    - [Using luarocks](#using-luarocks)
- [Usage](#usage)
- [User Commands](#user-commands)
- [Interactive Prompts](#interactive-prompts)
    - [Modified Buffer Prompt](#modified-buffer-prompt)
    - [Terminal Buffer Prompt](#terminal-buffer-prompt)
- [User Autocmds](#user-autocmds)
- [Credits](#credits)
- [Comparison with Existing Plugins](#comparison-with-existing-plugins)
- [Self-Promotion](#self-promotion)
- [License](#license)

<!-- vim-markdown-toc -->

## Requirements

- Neovim >= 0.10.0

## Installation

### Using [nvim-plug](https://github.com/wsdjeg/nvim-plug)

```lua
require('plug').add({
    'wsdjeg/bufdel.nvim',
})
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'wsdjeg/bufdel.nvim',
  cmd = { 'Bdelete', 'Bwipeout' },
  keys = {
    { '<leader>bd', '<cmd>Bdelete<cr>', desc = 'Delete buffer' },
    { '<leader>bD', '<cmd>Bdelete!<cr>', desc = 'Force delete buffer' },
    { '<leader>bw', '<cmd>Bwipeout<cr>', desc = 'Wipeout buffer' },
  },
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use('wsdjeg/bufdel.nvim')
```

### Using luarocks

```
luarocks install bufdel.nvim
```

## Usage

This plugin exposes a core `delete` function, which accepts two parameters: `buffers` and `opt`.

The buffers parameter specifies which buffers should be deleted. It supports multiple forms:

- A single integer (buffer number), `0` for current buffer.
- A string: it is first resolved to a buffer number using `bufnr(str)`.  
  If a valid buffer number is returned, that buffer is deleted.  
  Otherwise, the string is treated as a Vim regular expression and matched against buffer names.
- A table of integers or strings (each string follows the same resolution rule as above)
- A function, used to filter `vim.api.nvim_list_bufs()`. The function receives a buffer number as its argument and must return a boolean indicating whether the buffer should be deleted.

The `opt` parameter is a table used to control the deletion behavior. Supported keys include:

- `wipe`: whether to wipe the buffer (`bwipeout`) instead of deleting it (`bdelete`)
- `force`: force deletion even if the buffer is modified
- `ignore_user_events`: skip triggering `User BufDelPre` and `User BufDelPost` events
- `switch`: specify which buffer to switch to after deletion

**Default Behavior:**

The Lua API and user commands have different defaults for `switch`:

| Context                  | Default `switch` | Behavior                            |
| ------------------------ | ---------------- | ----------------------------------- |
| Lua API `delete()`       | `nil`            | Let Neovim decide                   |
| `:Bdelete` / `:Bwipeout` | `'lastused'`     | Switch to most recently used buffer |

Examples:

1. Delete a specific buffer

   Delete a single buffer by providing its buffer number.  
   This is useful when you already know exactly which buffer should be removed.

   ```lua
   require('bufdel').delete(2, { wipe = true })
   ```

   - The first argument is the buffer number to delete
   - The buffer must be valid
   - If `wipe = true`, the buffer is wiped (`:bwipeout`)
   - Otherwise, the buffer is deleted (`:bdelete`)

2. Delete multiple buffers

   Delete multiple buffers at once by passing a list of buffer numbers.

   ```lua
   require('bufdel').delete({ 2, 3, 5 }, { wipe = true })
   ```

   - Each item in the list must be a valid buffer number
   - Invalid or already-deleted buffers are ignored
   - Buffers are deleted in sequence
   - This is useful for batch-cleaning buffers

3. Delete buffers using a filter function

   Delete buffers dynamically by providing a filter function.  
   The function is called for each existing buffer and should return true
   if the buffer should be deleted.

   ```lua
   -- delete other saved buffers
   require('bufdel').delete(function(buf)
       return not vim.bo[buf].modified
           and vim.bo[buf].buflisted
           and buf ~= vim.api.nvim_get_current_buf()
   end, { wipe = true })
   ```

   - The filter function receives a buffer number
   - Return `true` to mark the buffer for deletion
   - Return `false` or `nil` to keep the buffer
   - This allows conditional deletion based on buffer state

4. Delete buffers whose names match a regular expression:

   ```lua
   require('bufdel').delete('.txt$', { wipe = true })
   ```

   - The buffer name is matched against a Vim regular expression
   - Only buffers whose names satisfy the pattern will be deleted
   - This is useful for cleaning up temporary or generated files

5. Specify the buffer to switch to after deletion

   By default, bufdel.nvim lets Neovim decide which buffer to display after a buffer is deleted.  
   You can override this behavior using the switch option to explicitly control which buffer to switch to after deletion.

   Use a function to customize the switch logic (recommended)

   ```lua
   require('bufdel').delete(function(buf)
       return not vim.bo[buf].modified and vim.bo[buf].buflisted
   end, {
       wipe = true,
       switch = function(deleted_buf)
           -- Return a valid buffer number
           return vim.fn.bufnr('#') -- switch to the alternate buffer
       end,
   })
   ```

   When switch is a function:

   - It receives the deleted buffer number (bufnr)
   - It must return a target bufnr
   - If the returned buffer is invalid, the switch is ignored

   Use built-in switch strategies

   ```lua
   require('bufdel').delete(filter, {
       wipe = true,
       switch = 'alt', -- alternate buffer (#)
   })
   ```

   Supported built-in values:

   - "alt" – alternate buffer (#)
   - "current" – keep the current buffer
   - "lastused" - the last used buffer
   - "next" – next buffer
   - "prev" – previous buffer

   Specify a buffer number directly

   ```lua
   require('bufdel').delete(filter, {
       wipe = true,
       switch = 3, -- switch to bufnr = 3
   })
   ```

## User Commands

bufdel.nvim provides two user commands `:Bdelete` and `:Bwipeout`, which work the same as `:bdelete` and `:bwipeout`,
but these commands preserve the window layout.

| Command               | Description                     |
| --------------------- | ------------------------------- |
| `:Bdelete [buf...]`   | Delete buffer(s)                |
| `:Bdelete! [buf...]`  | Force delete (discard changes)  |
| `:Bwipeout [buf...]`  | Wipe buffer(s) completely       |
| `:Bwipeout! [buf...]` | Force wipeout (discard changes) |

Examples:

1. Delete the current buffer
   ```
   :Bdelete
   ```
2. Delete a specific buffer by buffer number
   ```
   :Bdelete 3
   ```
3. Delete multiple buffers
   ```
   :Bdelete 2 5 7
   ```
4. Delete a range of buffers
   ```
   :3,6Bdelete
   ```
5. Force delete without saving
   ```
   :Bdelete!
   ```

**Features:**

- `<Tab>` completion for buffer names
- `!` bang modifier to force deletion
- Range support (`:3,6Bdelete`)
- Multiple buffer arguments

> **Note:**
> Because of limitations in Vim's Ex command parsing,
> buffer names that consist of digits only cannot be used with `:Bdelete <bufname>`.
> It is the same behavior as `:bdelete` and `:bwipeout`.
> In this case, please use the buffer number instead:
>
> ```
> :Bdelete <bufnr>
> ```

## Interactive Prompts

When deleting a buffer without `force=true` (or without `!` in commands), bufdel.nvim shows interactive prompts in certain situations:

### Modified Buffer Prompt

When attempting to delete a buffer with unsaved changes:

```
save changes to "filename"?  Yes/No/Cancel
```

- Press `y` (Yes): Save changes and delete the buffer
- Press `n` (No): Discard changes and force delete
- Press any other key: Cancel the deletion

### Terminal Buffer Prompt

When attempting to delete a terminal buffer with a running job:

```
Terminal buffer N is still running, killed?  Yes/No
```

- Press `y` (Yes): Kill the terminal job and delete the buffer
- Press any other key: Keep the terminal running (deletion cancelled)

## User Autocmds

bufdel.nvim triggers two user autocmds when deleting a buffer: `User BufDelPre` and `User BufDelPost`.
Here is an example to handle these events:

```lua
local mygroup = vim.api.nvim_create_augroup("bufdel_custom", { clear = true })
vim.api.nvim_create_autocmd({ "User" }, {
	group = mygroup,
	pattern = "BufDelPre",
	callback = function(ev)
        --- the deleted buffer number is saved in ev.data.buf
    end,
})
vim.api.nvim_create_autocmd({ "User" }, {
	group = mygroup,
	pattern = "BufDelPost",
	callback = function(ev)
        --- the deleted buffer number is saved in ev.data.buf
    end,
})
```

The `User BufDelPost` event will not be triggered if failed to delete the buffer.

## Credits

- [bufdelete.nvim](https://github.com/famiu/bufdelete.nvim)

The core logic of bufdel.nvim is derived from **bufdelete.nvim**.

## Comparison with Existing Plugins

Below is a minimal comparison of bufdel.nvim and several other buffer-deletion plugins
based on the features the author personally uses:

| Feature / Plugin          | bufdel.nvim | [bufdelete.nvim](https://github.com/famiu/bufdelete.nvim) | [nvim-bufdel](https://github.com/ojroques/nvim-bufdel) | [snacks.bufdelete](https://github.com/folke/snacks.nvim/blob/main/lua/snacks/bufdelete.lua) | [mini.bufremove](https://github.com/nvim-mini/mini.nvim/blob/main/lua/mini/bufremove.lua) |
| ------------------------- | ----------- | --------------------------------------------------------- | ------------------------------------------------------ | ------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| Preserve window layout    | ✓           | ✓                                                         | ✓                                                      | ✓                                                                                           | ✓                                                                                         |
| Delete by bufnr           | ✓           | ✓                                                         | ✓                                                      | ✓                                                                                           | ✓                                                                                         |
| Delete by bufname         | ✓           | ✓                                                         | ✓                                                      | ✓                                                                                           | ✗                                                                                         |
| User Command              | ✓           | ✓                                                         | ✓                                                      | ✗                                                                                           | ✗                                                                                         |
| Lua filter function       | ✓           | ✗                                                         | ✗                                                      | ✓                                                                                           | ✗                                                                                         |
| Regex buffer matching     | ✓           | ✗                                                         | ✗                                                      | ✗                                                                                           | ✗                                                                                         |
| Post-delete buffer switch | ✓           | ✓                                                         | ✓                                                      | ✗                                                                                           | ✗                                                                                         |
| User autocmd hooks        | ✓           | ✓                                                         | ✗                                                      | ✗                                                                                           | ✗                                                                                         |

Some plugins are actively maintained. For a more detailed comparison, you're encouraged to
try them and see which best fits your setup.  
If you notice any inaccuracies or mistakes in the comparison, please feel free to open an issue.

## Self-Promotion

Like this plugin? Star the repository on
[GitHub](https://github.com/wsdjeg/bufdel.nvim).

Love this plugin? Follow [me](https://wsdjeg.net/) on
[GitHub](https://github.com/wsdjeg) or [Twitter](https://x.com/EricWongDEV).

## License

This project is licensed under the GPL-3.0 License.
