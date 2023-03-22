local M = { histories = {} }

M.push = function()
  local winid = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_get_current_buf()
  local bufnm = vim.api.nvim_buf_get_name(bufnr)
  if not M.histories[winid] then M.histories[winid] = { index = 0, bufs = {} } end
  local h = M.histories[winid]
  if vim.bo.filetype == '' then return end

  local buf = h.bufs[h.index]
  if buf and buf.nr == bufnr then return end

  if h.index ~= #h.bufs then
    for i = #h.bufs, h.index + 1, -1 do
      table.remove(h.bufs, i)
    end
  end

  table.insert(h.bufs, { nr = bufnr, nm = bufnm })
  h.index = #h.bufs
end

M.back = function()
  local winid = vim.api.nvim_get_current_win()
  local h = M.histories[winid] or { index = 0 }
  if h.index > 1 then
    h.index = h.index - 1
    vim.api.nvim_set_current_buf(h.bufs[h.index].nr)
  end
end

M.forward = function()
  local winid = vim.api.nvim_get_current_win()
  local h = M.histories[winid] or { index = 0 }
  if h.index < #h.bufs then
    h.index = h.index + 1
    vim.api.nvim_set_current_buf(h.bufs[h.index].nr)
  end
end

M.setup = function(opts)
  local wilfred_denton_history_nvim = vim.api.nvim_create_augroup("WILFRED_DENTON_HISTORY_NVIM", {
    clear = true
  })

  vim.api.nvim_create_autocmd("BufEnter", {
    group = wilfred_denton_history_nvim,
    callback = M.push
  })

  vim.keymap.set('n', opts.keybinds.back or '<leader>bb', M.back)
  vim.keymap.set('n', opts.keybinds.forward or '<leader>bf', M.forward)
end

return M
