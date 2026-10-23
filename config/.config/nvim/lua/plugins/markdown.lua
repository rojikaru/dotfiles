return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      code = {
        disable_background = true,
        language_border = " ", -- fill with spaces instead of █
        highlight_border = false, -- no highlight on that line
      }, -- no box behind code blocks
      heading = { backgrounds = {} }, -- no bar behind headings
    },
  },
}
