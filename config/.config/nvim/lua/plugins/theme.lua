return {
  -- Other color schemes to try
  -- { "ellisonleao/gruvbox.nvim" },
  -- { "catppuccin/nvim", name = "catppuccin" },
  -- { "folke/tokyonight.nvim" },

  -- Current scheme
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    opts = {
      colors = {
        -- line numbers/signs share the editor bg
        theme = { all = { ui = { bg_gutter = "none" } } },
      },

      overrides = function(colors)
        local ui = colors.theme.ui
        return {
          -- match lualine's middle section
          StatusLine = { fg = ui.fg_dim, bg = ui.bg_p1 },

          -- terminal: same ink as code
          SnacksNormal = { link = "Normal" },
          SnacksNormalNC = { link = "Normal" },

          -- explorer (it is a picker)
          SnacksPicker = { link = "Normal" },
          SnacksPickerBorder = { fg = ui.float.fg_border, bg = ui.bg },

          -- label on the editor bg
          SnacksPickerTitle = { fg = colors.palette.carpYellow, bg = ui.bg, bold = true },

          -- the "h" badge
          SnacksPickerToggle = { fg = ui.special, bg = ui.bg },
        }
      end,
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      -- https://github.com/rebelot/kanagawa.nvim#configuration
      -- wave, lotus, dragon
      colorscheme = "kanagawa-dragon",
    },
  },
}
