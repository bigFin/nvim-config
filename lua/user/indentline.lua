local M = {
  "lukas-reineke/indent-blankline.nvim",
  event = "BufReadPre",
}
M.main = "ibl"
M.opts = {
  char = "▏",
  show_first_indent_level = true,
  use_treesitter = true,
  scope.enabled = true,
  buftype_exclude = { "terminal", "nofile" },
  filetype_exclude = {
    "help",
    "packer",
    "NvimTree",
  },
}

return M
