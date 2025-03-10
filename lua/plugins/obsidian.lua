return {
  "epwalsh/obsidian.nvim",
  version = "*",     -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
  --   "BufReadPre path/to/my-vault/**.md",
  --   "BufNewFile path/to/my-vault/**.md",
  -- },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",

    -- see below for full list of optional dependencies 👇
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "/Storage/logseq",
      },
      {
        name = "work",
        path = "/Code/avenueIntelligence/avenueIntelligence Logseq",
      },
    },

    daily_notes = {
      -- Optional, if you keep daily notes in a separate directory.
      folder = "journals",
      -- Optional, if you want to change the date format for the ID of daily notes.
      date_format = "%Y_%m_%d",
      -- Optional, if you want to change the date format of the default alias of daily notes.
      alias_format = "%B %-d, %Y",
      -- Optional, default tags to add to each new daily note created.
      default_tags = { "journals" },
      -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
      template = nil
    },

    -- Optional, completion of wiki links, local markdown links, and tags using nvim-cmp.
    completion = {
      -- Set to false to disable completion.
      nvim_cmp = true,
      -- Trigger completion at 2 chars.
      min_chars = 2,
      -- Custom wiki link function.
      wiki_link_func = function(link)
        -- Your custom function to handle wiki links.
        return link
      end,
    },

    -- New notes location (moved to top-level).
    new_notes_location = "pages",
  },
}
