# stand.nvim

> Time to stand reminders

## Install

```lua
{ "mvllow/stand.nvim" }
```

Optionally, install [nvim-notify](https://github.com/rcarriga/nvim-notify) for more prominent notifications.

## Usage

```lua
require("stand").setup()
```

## Options

```lua
require("stand").setup({
	minute_interval = 60
})
```

## Commands

`StandWhen` - Display time remaining until next stand

`StandNow` - Stand, dismissing any notifications and restarting the timer
