return require('packer').startup(function(use)
  -- Plugins here.
  use { 'neoclide/coc.nvim', branch = 'release' }
  use 'lervag/vimtex'

  --[[ On new systems install COC packages via
        CocInstall coc-vimtex coc-texlab
    --]]
end)
