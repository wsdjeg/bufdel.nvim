local M = {}

local function delete_buf(buf, opt)
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
		vim.api.nvim_buf_delete(buf, {})
	end
end

function M.delete(buf, opt)
	if type(buf) == "number" then
		delete_buf(buf, opt)
	elseif type(buf) == "function" then
		for _, v in ipairs(vim.api.nvim_list_bufs()) do
			if buf(v) then
				delete_buf(v, opt)
			end
		end
	end
end

return M
