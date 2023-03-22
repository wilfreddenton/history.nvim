local Path = require('plenary.path')
local popup = require('plenary.popup')

local M = { histories = {} }

local ignores = {
  [''] = true,
  ['netrw'] = true
}

local function to_relative_path(path)
  return Path:new(path):make_relative(vim.loop.cwd())
end

M.push = function()
  local winid = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_get_current_buf()
  local bufnm = to_relative_path(vim.api.nvim_buf_get_name(bufnr))
  if not M.histories[winid] then M.histories[winid] = { index = 0, bufs = {} } end
  local h = M.histories[winid]
  if ignores[vim.bo.filetype] then return end

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

M.history = function()
  local winid = vim.api.nvim_get_current_win()
  local h = M.histories[winid] or { index = 0, bufs = {} }
  local contents = {}
  for i, buf in ipairs(h.bufs) do
    table.insert(contents, buf.nm)
  end
  local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
  h_winid, h_bufnr = popup.create(contents, {
    title = "History",
    borderchars = borderchars,
    width = vim.api.nvim_win_get_width(winid) - 14,
  })
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
  vim.keymap.set('n', opts.keybinds.history or '<leader>bh', M.history)
end

return M
