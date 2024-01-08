# history.nvim

adds a browser-like buffer history to each window open in neovim.

## Install

```lua
use {
  'wilfreddenton/history.nvim',
  requires = { { 'nvim-lua/plenary.nvim' } }
}
```

## Setup

```lua
require('history').setup()
```

or 

```lua
require('history').setup({
  keybinds = {
    back = '<your custom keybind>',
    forward = '<your custom keybind>'
    view = '<your custom keybind>'
  }
  -- sets the title of window history popup
  popup_title = 'History',
  -- sets the width of the window history popup. Default vim.api.nvim_win_get_width(winid) - 10
  popup_width = false,
  -- determines whether keybinds are set within the plugin. Set to true by default
  set_keybinds = true
})
```

## Usage

Default keybinds:

- back: `<leader>bb`
- forward: `<leader>bf`
- view: `<leader>bv`

When the `view` popup is open, pressing `q`, `<Esc>`, or `<C-c>` will close it and
pressing enter (`<CR>`) on any line will navigate the window to the referenced file.

## Calling functions

If you want to call any of the three funcitons manually or if you choose not to have the plugin call set keybinds for you

```lua 
lua require('history').forward()
lua require('history').back()
lua require('history').toggle_popup()
```
