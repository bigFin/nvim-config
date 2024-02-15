return {
  config = function()
    require("telescope").load_extension("undo")
    vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>")
    require("telescope").load_extension("emoji")
    vim.keymap.set("n", "<leader>y", "<cmd>Telescope undo<cr>")
    require("telescope").load_extension("live_grep_args")
    vim.keymap.set("n", "<leader>fg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
  end,
}
