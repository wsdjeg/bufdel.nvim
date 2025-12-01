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

---@param buffers table<integer>
local function delete_buf(buffers, opt)
    local alt_buf = lastused_buf(buffers)
    if not alt_buf then alt_buf = vim.api.nvim_create_buf(true, false)
	for _, buf in ipairs(buffers) do
		if vim.o[buf].modified then
			vim.api.nvim_echo({
				{ 'save changes to "' .. vim.fn.bufname(buf) .. '"?  Yes/No/Cancel', "WarningMsg" },
			}, false, {})
			local c = vim.fn.getchar()
			if c == 121 then
				vim.api.nvim_buf_call(buf, function()
					vim.cmd("write")
				end)
			elseif c == 110 then
				vim.api.nvim_echo({
					{ "discarded!", "ModeMsg" },
				}, false, {})
			else
				vim.api.nvim_echo({
					{ "canceled!", "ModeMsg" },
				}, false, {})
			end
		else
            for _, w in ipairs(vim.fn.win_findbuf(buf)) do
                vim.api.nvim_win_set_buf(w, alt_buf)
            end
			vim.api.nvim_buf_delete(buf, {})
		end
	end
end

function M.delete(buf, opt)
	if type(buf) == "number" then
		delete_buf(buf, opt)
	elseif type(buf) == "function" then
        local del_bufs = {}
		for _, v in ipairs(vim.api.nvim_list_bufs()) do
			if buf(v) then
                table.insert(del_bufs, v)
			end
		end
        delete_buf(del_bufs, opt)
	end
end

return M
