---@class BufDel
local M = {}

---@param buf integer
---@param opt? vim.api.keyset.buf_delete
local function delete_buf(buf, opt)
	if not vim.o[buf].modified then
		vim.api.nvim_buf_delete(buf, opt or {})
		return
	end

	vim.api.nvim_echo({
		{ ('save changes to "%s"?  Yes/No/Cancel'):format(vim.fn.bufname(buf)), "WarningMsg" },
	}, false, { title = "bufdel.nvim" })
	local c = vim.fn.getchar()
	if c == 121 then
		vim.api.nvim_buf_call(buf, function()
			vim.cmd.write()
		end)
		return
	end
	if c == 110 then
		vim.api.nvim_echo({
			{ "discarded!", "ModeMsg" },
		}, false, { title = "bufdel.nvim" })
		return
	end

	vim.api.nvim_echo({
		{ "canceled!", "ModeMsg" },
	}, false, { title = "bufdel.nvim" })
end

---@param buf integer|fun(bufnr: integer): boolean
---@param opt? vim.api.keyset.buf_delete
function M.delete(buf, opt)
	if vim.is_callable(buf) then
		for _, v in ipairs(vim.api.nvim_list_bufs()) do
			if buf(v) then
				delete_buf(v, opt)
			end
		end
		return
	end
	if type(buf) == "number" then
		delete_buf(buf, opt)
		return
	end
end

return M
-- vim:ts=4:sts=4:sw=0:noet:ai:si:sta:
