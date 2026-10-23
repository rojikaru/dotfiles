return {
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "VeryLazy",
    config = function()
      local rainbow = require("rainbow-delimiters")
      vim.g.rainbow_delimiters = {
        strategy = { [""] = rainbow.strategy["global"] },
        query = { [""] = "rainbow-delimiters", lua = "rainbow-blocks" },
        highlight = {
          "RainbowDelimiterYellow",
          "RainbowDelimiterViolet",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterCyan",
          "RainbowDelimiterRed",
        },
      }
    end,
  },
}
