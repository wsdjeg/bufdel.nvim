local lu = require('luaunit')
local bufdel = require('bufdel')

TestBufDel = {}

function TestBufDel:setUp()
  -- Create test buffers
  self.buf1 = vim.api.nvim_create_buf(true, false)
  self.buf2 = vim.api.nvim_create_buf(true, false)
  self.buf3 = vim.api.nvim_create_buf(true, false)
end

function TestBufDel:tearDown()
  -- Clean up buffers
  for _, buf in ipairs({ self.buf1, self.buf2, self.buf3 }) do
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
end

function TestBufDel:test_delete_single_buffer()
  local buf = vim.api.nvim_create_buf(true, false)
  bufdel.delete(buf, { force = true })
  -- non-wipe delete: buffer is unloaded and unlisted, but still valid
  lu.assertTrue(vim.api.nvim_buf_is_valid(buf))
  lu.assertFalse(vim.bo[buf].buflisted)
  -- clean up
  vim.api.nvim_buf_delete(buf, { force = true })
end

function TestBufDel:test_delete_multiple_buffers()
  local buf1 = vim.api.nvim_create_buf(true, false)
  local buf2 = vim.api.nvim_create_buf(true, false)
  bufdel.delete({ buf1, buf2 }, { force = true })
  -- non-wipe delete: buffers are unlisted but still valid
  lu.assertFalse(vim.bo[buf1].buflisted)
  lu.assertFalse(vim.bo[buf2].buflisted)
  -- clean up
  vim.api.nvim_buf_delete(buf1, { force = true })
  vim.api.nvim_buf_delete(buf2, { force = true })
end

function TestBufDel:test_delete_with_filter_function()
  local buf1 = vim.api.nvim_create_buf(true, false)
  local buf2 = vim.api.nvim_create_buf(true, false)
  -- Delete only buf1 using a filter function
  bufdel.delete(function(bufnr)
    return bufnr == buf1
  end, { force = true })
  -- non-wipe delete: buf1 is unlisted, buf2 is still listed
  lu.assertFalse(vim.bo[buf1].buflisted)
  lu.assertTrue(vim.bo[buf2].buflisted)
  -- clean up
  vim.api.nvim_buf_delete(buf1, { force = true })
  vim.api.nvim_buf_delete(buf2, { force = true })
end

function TestBufDel:test_wipe_buffer()
  local buf = vim.api.nvim_create_buf(true, false)
  bufdel.delete(buf, { wipe = true, force = true })
  -- wipe delete: buffer is completely gone
  lu.assertFalse(vim.api.nvim_buf_is_valid(buf))
end

function TestBufDel:test_regex_to_bufs()
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(buf, 'test_regex_buffer.txt')
  local bufs = bufdel.regex_to_bufs('test_regex_buffer')
  lu.assertTrue(vim.tbl_contains(bufs, buf))
  vim.api.nvim_buf_delete(buf, { force = true })
end

return TestBufDel

