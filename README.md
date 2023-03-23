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
})
```

## Usage

Default keybinds:

- back: `<leader>bb`
- forward: `<leader>bf`
- view: `<leader>bv`

When the `view` popup is open, pressing `q`, `<Esc>`, or `<C-c>` will close it and
pressing enter (`<CR>`) on any line will navigate the window to the referenced file.
