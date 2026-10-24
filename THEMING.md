# Theming

## Color sources

| Program | Source | File |
| --- | --- | --- |
| Neovim | kanagawa-dragon | `config/.config/nvim/lua/plugins/theme.lua` |
| kitty | wallust (wallpaper) | `config/.config/wallust/templates/kitty.conf` |
| Waybar, rofi, cava | wallust (wallpaper) | `config/.config/wallust/wallust.toml` |
| swaync | wallust and matugen | `config/.config/swaync/` |

## kitty <-> Neovim

kitty paints its padding with its own background color.
If this color is not the same as the Neovim background, you see a frame.

To prevent this, `lua/config/autocmds.lua` sends the Neovim background to kitty:

- Neovim starts or the color scheme changes -> kitty uses the Neovim background.
- Neovim stops -> kitty uses the background from `kitty.conf` again.

This works with all color schemes.
Reference: <https://sw.kovidgoyal.net/kitty/color-stack/>

## Opacity

- kitty: `background_opacity 1`. With a transparent background, the text was hard to read.
- Hyprland: `active_opacity` and `inactive_opacity` also make text transparent.
  A window rule in `21-windows.lua` sets kitty to `1.0 override`.

## Neovim overrides (kanagawa)

The overrides are in `theme.lua`. They work for all kanagawa variants.
They do not work for other color schemes.

| Setting | Problem |
| --- | --- |
| `bg_gutter = "none"` | The line number column had a different color. |
| `StatusLine` | The statusline had dark boxes between symbols. |
| `SnacksNormal`, `SnacksNormalNC` | The terminal was darker than the code. |
| `SnacksPicker`, `SnacksPickerBorder` | The explorer was darker than the code. |
| `SnacksPickerTitle`, `SnacksPickerToggle` | The explorer label had a dark box. |

Not changed:

- The tab bar is darker. Bufferline sets its own colors.
- Snacks makes the screen darker behind lazygit.
  To stop this, add `lazygit = { win = { backdrop = false } }` to `snacks.lua`.

## Change the color scheme

1. To try a color scheme, type `<leader>uC` or `:colorscheme <name>`.
2. To keep it, change `colorscheme` in `theme.lua`.

The kitty background changes automatically. The kitty text colors do not change.

## Find the cause of a color problem

| Question | Command |
| --- | --- |
| Which group gives this color? | `:Inspect` |
| Which groups does this window use? | `:lua =vim.wo.winhighlight` |
| Which color does a group have? | `:hi <Group>` |
| Which key does kitty get? | `kitty --debug-input` |
| Which bytes does the shell get? | `ctrl+v`, then the key |
| Why is swaync wrong? | `pkill swaync; GTK_DEBUG=interactive swaync` |

## Known problems

New files in `~/.config/nvim/lua/plugins/` are not linked automatically.
After you add a file, run `restow`.
