# history.nvim

adds a browser-like buffer history to each window open in neovim.

## Install

```lua
use 'wilfreddenton/history.nvim'
```

## Setup

```lua
require('history')
```

or 

```lua
require('history').setup({
  keybinds = {
    back = '<your back keybind>',
    forward = '<your forward keybind>'
  }
})
```

## Usage

By default, use `<leader>bb` to go back in buffer history and `<leader>bf`  to go forward in buffer history.
