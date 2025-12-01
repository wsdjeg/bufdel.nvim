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
---@field wipe boolean
---@field event boolean set to false to disable User autocmd

---@param buffers table<integer>
---@param opt? BufDelOpts
local function delete_buf(buffers, opt)
	local alt_buf = lastused_buf(buffers)
	if not alt_buf then
		alt_buf = vim.api.nvim_create_buf(true, false)
	end
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
			vim.api.nvim_exec_autocmds("User", { pattern = "BufDelPro", data = { buf = buf } })
			local wipe = opt and opt.wipe
			vim.api.nvim_buf_delete(buf, { unload = not wipe })
			vim.api.nvim_exec_autocmds("User", { pattern = "BufDelPost", data = { buf = buf } })
		end
	end
end

---@param buf integer|fun(bufnr: integer): boolean
---@param opt? BufDelOpts
function M.delete(buf, opt)
	if vim.is_callable(buf) then
		local del_bufs = {}
		for _, v in ipairs(vim.api.nvim_list_bufs()) do
			if buf(v) then
				table.insert(del_bufs, v)
			end
		end
		delete_buf(del_bufs, opt)
	elseif type(buf) == "number" then
		delete_buf({ buf }, opt)
	elseif type(buf) == "table" then
		delete_buf(buf, opt)
	end
end

return M
-- vim:ts=4:sts=4:sw=0:noet:ai:si:sta:
