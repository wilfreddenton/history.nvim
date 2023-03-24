local Path = require('plenary.path')
local popup = require('plenary.popup')

local M = { histories = {} }

local IGNORES = {
  [''] = true,
  ['netrw'] = true
}

local POPUP_WINID = nil

local function to_relative_path(path)
  return Path:new(path):make_relative(vim.loop.cwd())
end

M.push = function()
  local winid = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_get_current_buf()
  local bufnm = to_relative_path(vim.api.nvim_buf_get_name(bufnr))
  if not M.histories[winid] then M.histories[winid] = { index = 0, bufs = {} } end
  local h = M.histories[winid]
  if IGNORES[vim.bo.filetype] then return end

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

M.select_file_in_history = function()
  local index = vim.api.nvim_win_get_cursor(POPUP_WINID)[1]
  M.toggle_popup()
  local winid = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_buf(M.histories[winid].bufs[index].nr)
end

M.toggle_popup = function()
  if POPUP_WINID and vim.api.nvim_win_is_valid(POPUP_WINID) then
    vim.api.nvim_win_close(POPUP_WINID, true)
    POPUP_WINID = nil
    return
  end

  if IGNORES[vim.bo.filetype] then return end

  local winid = vim.api.nvim_get_current_win()
  local h = M.histories[winid]
  if not h then return end

  local contents = {}
  for _, buf in ipairs(h.bufs) do
    table.insert(contents, buf.nm)
  end
  POPUP_WINID = popup.create(contents, {
    title = "History",
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    width = vim.api.nvim_win_get_width(winid) - 10,
  })
  local bufnr = vim.api.nvim_win_get_buf(POPUP_WINID)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<Cmd> lua require('history').toggle_popup()<CR>", {})
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<Esc>", "<Cmd> lua require('history').toggle_popup()<CR>", {})
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-c>", "<Cmd> lua require('history').toggle_popup()<CR>", {})
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<CR>", "<Cmd> lua require('history').select_file_in_history()<CR>", {})
  vim.api.nvim_buf_add_highlight(bufnr, 0, "Identifier", h.index - 1, 0, -1)
  vim.api.nvim_win_set_option(POPUP_WINID, "number", true)
  vim.api.nvim_win_set_cursor(POPUP_WINID, { h.index, 0 })
  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = bufnr,
    nested = true,
    once = true,
    callback = M.toggle_popup
  })
end

M.setup = function(opts)
  if not opts then opts = {} end
  if not opts.keybinds then opts.keybinds = {} end

  local wilfred_denton_history_nvim = vim.api.nvim_create_augroup("WILFRED_DENTON_HISTORY_NVIM", {
    clear = true
  })

  vim.api.nvim_create_autocmd("BufEnter", {
    group = wilfred_denton_history_nvim,
    callback = M.push
  })

  vim.keymap.set('n', opts.keybinds.back or '<leader>bb', M.back)
  vim.keymap.set('n', opts.keybinds.forward or '<leader>bf', M.forward)
  vim.keymap.set('n', opts.keybinds.view or '<leader>bv', M.toggle_popup)
end

return M
