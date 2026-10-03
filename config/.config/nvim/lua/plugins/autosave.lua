return {
  "okuuva/auto-save.nvim",
  cmd = "ASToggle", -- optional for lazy loading on command
  event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
  opts = {
    enabled = true,
    execution_message = {
      message = function()
        return ""
      end, -- disables the save notification message
    },
    debounce_delay = 1000, -- time in ms before saving
  },
}
