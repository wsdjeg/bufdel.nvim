# bufdel.nvim

bufdel.nvim is a neovim plugin that helps you delete buffers without changing windows layout.

[![GitHub License](https://img.shields.io/github/license/wsdjeg/bufdel.nvim)](LICENSE)
[![GitHub Issues or Pull Requests](https://img.shields.io/github/issues/wsdjeg/bufdel.nvim)](https://github.com/wsdjeg/bufdel.nvim/issues)
[![GitHub commit activity](https://img.shields.io/github/commit-activity/m/wsdjeg/bufdel.nvim)](https://github.com/wsdjeg/bufdel.nvim/commits/master/)
[![GitHub Release](https://img.shields.io/github/v/release/wsdjeg/bufdel.nvim)](https://github.com/wsdjeg/bufdel.nvim/releases)
[![luarocks](https://img.shields.io/luarocks/v/wsdjeg/bufdel.nvim)](https://luarocks.org/modules/wsdjeg/bufdel.nvim)

<!-- vim-markdown-toc GFM -->

- [Installation](#installation)
- [Usage](#usage)
- [User Commands](#user-commands)
- [User Autocmds](#user-autocmds)
- [Credits](#credits)
- [Self-Promotion](#self-promotion)
- [License](#license)

<!-- vim-markdown-toc -->

## Installation

Using [nvim-plug](https://github.com/wsdjeg/nvim-plug)

```lua
require('plug').add({
    'wsdjeg/bufdel.nvim',
})
```

Using luarocks

```
luarocks install bufdel.nvim
```

## Usage

1. Delete a specific buffer

   Delete a single buffer by providing its buffer number.  
   This is useful when you already know exactly which buffer should be removed.

   ```lua
   require("bufdel").delete(2, { wipe = true })
   ```

   - The first argument is the buffer number to delete
   - The buffer must be valid
   - If `wipe = true`, the buffer is wiped (`:bwipeout`)
   - Otherwise, the buffer is deleted (`:bdelete`)

2. Delete multiple buffers

   Delete multiple buffers at once by passing a list of buffer numbers.

   ```lua
   require("bufdel").delete({ 2, 3, 5 }, { wipe = true })
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
   require("bufdel").delete(function(buf)
   return not vim.bo[buf].modified and vim.bo[buf].buflisted
   end, { wipe = true })
   ```

   - The filter function receives a buffer number
   - Return `true` to mark the buffer for deletion
   - Return `false` or `nil` to keep the buffer
   - This allows conditional deletion based on buffer state

   Delete buffers whose names match a regular expression:

   ```lua
   require("bufdel").delete(function(buf)
   local regex = ".txt$"
   return vim.regex(regex):match_str(vim.api.nvim_buf_get_name(buf))
   end, { wipe = true })
   ```

   - The buffer name is matched against a Vim regular expression
   - Only buffers whose names satisfy the pattern will be deleted
   - This is useful for cleaning up temporary or generated files

4. Specify the buffer to switch to after deletion

   By default, bufdel.nvim lets Neovim decide which buffer to display after a buffer is deleted.  
   You can override this behavior using the switch option to explicitly control which buffer to switch to after deletion.

   Use a function to customize the switch logic (recommended)

   ```lua
   require("bufdel").delete(
     function(buf)
       return not vim.bo[buf].modified and vim.bo[buf].buflisted
     end,
     {
       wipe = true,
       switch = function(deleted_buf)
         -- Return a valid buffer number
         return vim.fn.bufnr("#") -- switch to the alternate buffer
       end,
     }
   )
   ```

   When switch is a function:

   - It receives the deleted buffer number (bufnr)
   - It must return a target bufnr
   - If the returned buffer is invalid, the switch is ignored

   Use built-in switch strategies

   ```lua
   require("bufdel").delete(filter, {
     wipe = true,
     switch = "alt", -- alternate buffer (#)
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
   require("bufdel").delete(filter, {
     wipe = true,
     switch = 3, -- switch to bufnr = 3
   })
   ```

## User Commands

bufdel.nvim also provides two user commands `:Bdelete` and `:Bwipeout`, which is just same as `:delete` and `:bwipeout`,
but these user commands will not change the windows layout.

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

## User Autocmds

bufdel.nvim triggers two user autocmds when delete a buffer, `User BufDelPro` and `User BufDelPost`.
here is an example to handled these events:

```lua
local mygroup = vim.api.nvim_create_augroup("bufdel_custom", { clear = true })
vim.api.nvim_create_autocmd({ "User" }, {
	group = mygroup,
	pattern = "BufDelPro",
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
- [Snacks.bufdelete](https://github.com/folke/snacks.nvim/blob/main/docs/bufdelete.md)
- [nvim-bufdel](https://github.com/ojroques/nvim-bufdel)

## Self-Promotion

Like this plugin? Star the repository on
GitHub.

Love this plugin? Follow [me](https://wsdjeg.net/) on
[GitHub](https://github.com/wsdjeg) or [Twitter](https://x.com/EricWongDEV).

## License

This project is licensed under the GPL-3.0 License.
