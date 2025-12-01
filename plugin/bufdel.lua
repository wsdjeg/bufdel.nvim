local function get_delete_bufs(opt)
    if #opt.fargs == 0 then
        if opt.range == 0 then
            return vim.api.nvim_get_current_buf()
        else
            local range = { tonumber(opt.line1), tonumber(opt.line2) }
            table.sort(range)
            return vim.tbl_filter(function(t)
                return t > range[1] and t <= range[2]
            end, vim.api.nvim_list_bufs())
        end
    end
    local buffers = {}
    for _, b in ipairs(opt.fargs) do
        if vim.fn.bufnr(b) > 0 then
            table.insert(buffers, vim.fn.bufnr(b))
        elseif tonumber(b) then
            table.insert(buffers, tonumber(b))
        end
    end
    return buffers
end

vim.api.nvim_create_user_command('Bdelete', function(opt)
    require('bufdel').delete(get_delete_bufs(opt), { force = opt.bang })
end, {
    nargs = '*',
    bang = true,
    range = true,
    addr = 'buffers',
    complete = require('bufdel').complete,
})
vim.api.nvim_create_user_command('Bwipeout', function(opt)
    require('bufdel').delete(get_delete_bufs(opt), { wipe = true, force = opt.bang })
end, {
    nargs = '*',
    bang = true,
    range = true,
    addr = 'buffers',
    complete = require('bufdel').complete,
})
