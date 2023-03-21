# history.nvim

adds a browser-like buffer history to each window open in neovim.

## Install

```lua
use '~/lua/history.nvim/'
```

## Setup

```lua
require('history')
```

or 

```
require('history').setup({
  keybinds = {
    back = '<your back keybind>',
    forward = '<your back keybind>'
  }
})
```

## Usage

By default, use `<leader>bb` to go back in buffer history and `<leader>bf`  to go forward in buffer history.
