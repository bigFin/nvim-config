return {
  config = function()
    require("telescope").setup({
      extensions = {
        undo = {
          -- telescope-undo.nvim config, see below
        },
        emoji = {
          action = function(emoji)
            -- argument emoji is a table.
            -- {name="", value="", cagegory="", description=""}
            vim.fn.setreg("*", emoji.value)
            print([[Press p or "*p to paste this emoji]] .. emoji.value)   -- insert emoji when picked
            vim.api.nvim_put({ emoji.value }, 'c', false, true)
          end,
        }
      },
    })

    require("telescope").load_extension("undo")
    vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>")
    require("telescope").load_extension("emoji")
    vim.keymap.set("n", "<leader>y", "<cmd>Telescope undo<cr>")
    require("telescope").load_extension("live_grep_args")
    vim.keymap.set("n", "<leader>fg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
  end,
}
