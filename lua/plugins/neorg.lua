return {
	 
	require("lazy").setup({
  {
      "nvim-neorg/neorg",
      build = ":Neorg sync-parsers",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        require("neorg").setup {
          load = {
            ["core.defaults"] = {}, -- Loads default behaviour
            ["core.concealer"] = {}, -- Adds pretty icons to your documents
            ["core.dirman"] = { -- Manages Neorg workspaces
              config = {
workspaces = {
                logseq = "/Storage/logseq",
                journals = "/Storage/logseq/journals",
                avenue = "/Code/avenueOrg"
              },
              },
            },
          },
        }
      end,
      }})}
