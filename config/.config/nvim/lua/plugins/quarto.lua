local function insert_chunk(header)
  return function()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_buf_set_lines(0, row, row, false, { "", "```" .. header, "", "```", "" })
    vim.api.nvim_win_set_cursor(0, { row + 3, 0 })
    vim.cmd("startinsert")
  end
end

local function insert_markdown()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, row, row, false, { "", "", "" })
  vim.api.nvim_win_set_cursor(0, { row + 2, 0 })
  vim.cmd("startinsert")
end

return {
  {
    "quarto-dev/quarto-nvim",
    ft = { "quarto" },
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      lspFeatures = {
        enabled = true,
        chunks = "curly",
        languages = { "r", "python", "julia", "bash", "html" },
        diagnostics = { enabled = true, triggers = { "BufWritePost" } },
        completion = { enabled = true },
      },
      codeRunner = {
        enabled = true,
        default_method = "molten",
        never_run = { "yaml" },
      },
    },
    keys = {
      {
        "<leader><CR>",
        function()
          require("quarto.runner").run_cell()
        end,
        ft = "quarto",
        desc = "Run cell",
      },
      {
        "<leader>ra",
        function()
          require("quarto.runner").run_above()
        end,
        ft = "quarto",
        desc = "Run cell and above",
      },
      {
        "<leader>rA",
        function()
          require("quarto.runner").run_all()
        end,
        ft = "quarto",
        desc = "Run all cells",
      },
      {
        "<leader>rl",
        function()
          require("quarto.runner").run_line()
        end,
        ft = "quarto",
        desc = "Run line",
      },
      {
        "<leader>r",
        function()
          require("quarto.runner").run_range()
        end,
        ft = "quarto",
        mode = "v",
        desc = "Run selection",
      },
      { "<leader>rp", "<cmd>QuartoPreview<cr>", ft = "quarto", desc = "Quarto preview" },
      { "<leader>ip", insert_chunk("{python}"), ft = "quarto", desc = "New python cell" },
      { "<leader>it", insert_chunk("{=typst}"), ft = "quarto", desc = "New typst block" },
      { "<leader>im", insert_markdown, ft = "quarto", desc = "New markdown (prose)" },
    },
  },
  {
    "benlubas/molten-nvim",
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.python3_host_prog = vim.fn.expand("~/.venvs/quarto/bin/python")
      vim.g.molten_image_provider = "image.nvim" -- needs a compatible terminal
      vim.g.molten_auto_open_output = false
      vim.g.molten_virt_text_output = true
      vim.g.molten_wrap_output = true
    end,
  },
  { "3rd/image.nvim", opts = {} },
}
