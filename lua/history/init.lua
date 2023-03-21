local M = { histories = {} }

M.push = function()
  local winid = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_get_current_buf()
  if not M.histories[winid] then M.histories[winid] = { index = 0, bufnrs = {} } end
  local h = M.histories[winid]
  if vim.bo.filetype == '' then return end

  local bufnr_at_index = h.bufnrs[h.index]
  if bufnr_at_index and bufnr_at_index == bufnr then return end

  if h.index ~= #h.bufnrs then
    for i = h.index + 1, #h.bufnrs do
      table.remove(h.bufnrs, i)
    end
  end

  table.insert(h.bufnrs, bufnr)
  h.index = #h.bufnrs
end

M.back = function()
  local winid = vim.api.nvim_get_current_win()
  local h = M.histories[winid] or { index = 0 }
  if h.index > 1 then
    h.index = h.index - 1
    vim.api.nvim_set_current_buf(h.bufnrs[h.index])
  end
end

M.forward = function()
  local winid = vim.api.nvim_get_current_win()
  local h = M.histories[winid] or { index = 0 }
  if h.index < #h.bufnrs then
    h.index = h.index + 1
    vim.api.nvim_set_current_buf(h.bufnrs[h.index])
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
