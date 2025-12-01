local function fargs_to_buffers(fargs)
    if #fargs == 0 then
        return vim.api.nvim_get_current_buf()
    end
    local buffers = {}
    for _, b in ipairs(fargs) do
        if vim.fn.bufnr(b) > 0 then
            table.insert(buffers, vim.fn.bufnr(b))
        elseif tonumber(b) then
            table.insert(buffers, tonumber(b))
        end
    end
    return buffers
end

vim.api.nvim_create_user_command('Bdelete', function(opt)
    require('bufdel').delete(fargs_to_buffers(opt.fargs), { force = opt.bang })
end, {
    nargs = '*',
    bang = true,
    range = true,
    complete = require('bufdel').complete,
})
vim.api.nvim_create_user_command('Bwipeout', function(opt)
    require('bufdel').delete(fargs_to_buffers(opt.fargs), { wipe = true, force = opt.bang })
end, {
    nargs = '*',
    bang = true,
    range = true,
    complete = require('bufdel').complete,
})
