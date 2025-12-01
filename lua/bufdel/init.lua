---@class BufDel
local M = {}

local function lastused_buf(buffers)
    local info = vim.fn.getbufinfo({ buflisted = 1 })
    info = vim.tbl_filter(function(i)
        return not vim.tbl_contains(buffers, i.bufnr)
    end, info)
    table.sort(info, function(a, b)
        return a.lastused > b.lastused
    end)

    return info[1] and info[1].bufnr
end

---@class BufDelOpts
---@field wipe? boolean
---@field force? boolean discard changes
---@field ignore_user_events? boolean set to true to disable User autocmd

---@param buffers table<integer>
---@param opt BufDelOpts
local function delete_buf(buffers, opt)
    local alt_buf = lastused_buf(buffers)
    if not alt_buf then
        alt_buf = vim.api.nvim_create_buf(true, false)
    end
    for _, buf in ipairs(buffers) do
        if vim.bo[buf].modified and not opt.force then
            vim.api.nvim_echo({
                -- yes: save and delete
                -- no: do not save, force delete
                -- cancel: do not save, do not delete
                { 'save changes to "' .. vim.fn.bufname(buf) .. '"?  Yes/No/Cancel', 'WarningMsg' },
            }, false, {})
            local c = vim.fn.getchar()
            --save changes to "lua\bufdel\init.lua"?  Yes/No/Cancel
            -- canceled!
            -- Press ENTER or type command to continue
            -- @fixme can not clear the cmdline?
            vim.cmd.mode()
            if c == 121 then
                vim.api.nvim_buf_call(buf, function()
                    vim.cmd('write')
                end)
                delete_buf({ buf }, opt)
            elseif c == 110 then
                vim.api.nvim_echo({
                    { 'discarded!', 'ModeMsg' },
                }, false, {})
                delete_buf(
                    { buf },
                    { wipe = opt.wipe, force = true, ignore_user_events = opt.ignore_user_events }
                )
            else
                vim.api.nvim_echo({
                    { 'canceled!', 'ModeMsg' },
                }, false, {})
            end
        elseif vim.bo[buf].buftype == 'terminal' and not opt.force then
            -- handle terminal buffer
            if vim.fn.jobwait({ vim.bo[buf].channel }, 0)[1] == -1 then
                vim.api.nvim_echo({
                    -- yes: save and delete
                    -- no: do not save, force delete
                    -- cancel: do not save, do not delete
                    {
                        'Terminal buffer ' .. buf .. ' is still running, killed?  Yes/No',
                        'WarningMsg',
                    },
                }, false, {})
                local c = vim.fn.getchar()
                vim.cmd.mode()
                if c == 121 then
                    vim.cmd.redraw()
                    delete_buf({ buf }, { wipe = true, force = true })
                else
                    vim.api.nvim_echo({
                        { 'Keep running', 'ModeMsg' },
                    }, false, {})
                end
            end
        else
            for _, w in ipairs(vim.fn.win_findbuf(buf)) do
                if vim.api.nvim_get_option_value('winfixbuf', { win = w }) == true then
                else
                    vim.api.nvim_win_set_buf(w, alt_buf)
                end
            end
            -- for bufhide=wipe
            if not vim.api.nvim_buf_is_valid(buf) then
                -- buf does not exists, skiped
                return
            end
            if not opt.ignore_user_events then
                vim.api.nvim_exec_autocmds('User', { pattern = 'BufDelPro', data = { buf = buf } })
            end
            --@fixme this logic maybe changed
            local wipe = opt and opt.wipe
            -- https://github.com/neovim/neovim/issues/33314
            -- https://github.com/neovim/neovim/issues/33314#issuecomment-2780814695
            local ok, err =
                pcall(vim.api.nvim_buf_delete, buf, { unload = not wipe, force = opt.force })
            if not ok then
                -- if failed to run nvim_buf_delete, BufDelPost event will not be triggered.
                return
            end
            if not wipe then
                vim.api.nvim_set_option_value('buflisted', false, { buf = buf })
            end
            if not opt.ignore_user_events then
                vim.api.nvim_exec_autocmds('User', { pattern = 'BufDelPost', data = { buf = buf } })
            end
        end
    end
end

---@param buf integer|table<integer>|fun(bufnr: integer): boolean
---@param opt? BufDelOpts
function M.delete(buf, opt)
    opt = opt or {}
    if vim.is_callable(buf) then
        local del_bufs = {}
        for _, v in ipairs(vim.api.nvim_list_bufs()) do
            if buf(v) then
                table.insert(del_bufs, v)
            end
        end
        delete_buf(del_bufs, opt)
    elseif type(buf) == 'number' then
        delete_buf({ buf }, opt)
    elseif type(buf) == 'table' then
        delete_buf(buf, opt)
    end
end

function M.complete(lead, cmdline, pos)
    local bufs = vim.tbl_filter(function(t)
        return vim.bo[t].buflisted and vim.api.nvim_buf_get_name(t):find(lead)
    end, vim.api.nvim_list_bufs())

    return vim.tbl_map(function(t)
        return vim.fn.bufname(t)
    end, bufs)
end

return M
-- vim:ts=4:sts=4:sw=0:noet:ai:si:sta:
