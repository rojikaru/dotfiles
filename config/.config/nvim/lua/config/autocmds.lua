-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local function kitty_bg(value)
  vim.api.nvim_chan_send(vim.v.stderr, "\027]21;" .. value .. "\007")
end

local function sync_bg()
  local bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg
  if bg then
    kitty_bg(("background=#%06x"):format(bg))
  end
end

-- While nvim runs, kitty's background follows the colorscheme (no frame);
-- on exit, kitty goes back to its own background.
vim.api.nvim_create_autocmd({ "ColorScheme", "VimResume" }, { callback = sync_bg })
vim.api.nvim_create_autocmd({ "VimLeavePre", "VimSuspend" }, {
  callback = function()
    kitty_bg("background") -- key without a value = reset to kitty.conf's background
  end,
})
sync_bg()
