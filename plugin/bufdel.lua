vim.api.nvim_create_user_command('Bdelete', function(opt)
    local bufdel = require('bufdel')
    bufdel.delete(bufdel.cmd_to_buffers(opt), { force = opt.bang })
end, {
    nargs = '*',
    bang = true,
    range = true,
    addr = 'buffers',
    complete = require('bufdel').complete,
})
vim.api.nvim_create_user_command('Bwipeout', function(opt)
    local bufdel = require('bufdel')
    bufdel.delete(bufdel.cmd_to_buffers(opt), { wipe = true, force = opt.bang })
end, {
    nargs = '*',
    bang = true,
    range = true,
    addr = 'buffers',
    complete = require('bufdel').complete,
})
