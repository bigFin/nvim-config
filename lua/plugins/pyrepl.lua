return {
    "yacineMTB/pyrepl.nvim",
    dependencies = {'nvim-lua/plenary.nvim'},
    config = function()
    require("pyrepl").setup({
        url = "http://localhost:5000/execute"
    })
    end,
    keys = {
        {"<leader>p", function() require('pyrepl').run_selected_lines() end, mode = "v", desc = "Run selected lines"},
        {
            "<leader>P",
            function()
            vim.cmd('normal! ggVG')
            require('pyrepl').run_selected_lines()
            end,
            mode = "n",
            desc = "Run entire buffer"
        }
    }
}
