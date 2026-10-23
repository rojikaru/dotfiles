return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          files = { hidden = true, ignored = false },
          grep = { hidden = true, ignored = false },
          explorer = { hidden = true, ignored = false },
        },
      },
      explorer = {
        enabled = true,
        follow_file = true,
        replace_netrw = true,
        auto_close = false,
        focus = "list",

        win = {
          list = {
            keys = {
              ["l"] = "confirm",
              ["h"] = "close_node",
              ["a"] = "explorer_add",
              ["d"] = "explorer_del",
              ["r"] = "explorer_rename",
              ["y"] = "explorer_yank",
              ["p"] = "explorer_paste",
            },
          },
        },
      },
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {},
  },
}
