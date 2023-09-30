# tailwind-linter.nvim
Checks content inside class="" to see if it matches the tailwind class order (taken from headwind)

### Fix sort order command
`:TailwindLinterFix`

### Example install for lazy
```lua
return {
    'SushyDev/tailwind-linter.nvim',
    config = function ()
        require('tailwind-linter').setup({})
    end
}
```

### Options
```lua
{
    prefix = "", --message prefix
    message = "Tailwind classes are not in the correct order.", --message
    type = "@error", --highlight group
    languages = { "html", "php" },
}
```
