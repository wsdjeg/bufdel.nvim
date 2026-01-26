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

1. delete a specific buffer:

```lua
require('bufdel').delete(2, { wipe = true })
```

2. delete more than one buffers:

```lua
require('bufdel').delete({ 2, 3, 5 }, { wipe = true })
```

3. delete buffers with filter function:

```lua
require('bufdel').delete(function(buf)
    return not vim.bo[buf].modified and vim.bo[buf].buflisted
end, { wipe = true })

-- delete buffers based on regex
require('bufdel').delete(function(buf)
    local regex = '.txt$'
    if vim.regex(regex):match_str(vim.api.nvim_buf_get_name(buf)) then
        return true
    end
end, { wipe = true })
```



## User Commands

bufdel.nvim also provides two user commands `:Bdelete` and `:Bwipeout`, which is just same as `:delete` and `:bwipeout`,
but these user commands will not change the windows layout.

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
