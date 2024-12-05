return {
  'boganworld/crackboard.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('crackboard').setup({
      session_key = '60f6f2fa25124e327d8b9be0715b508b0c1461854bb28d61f19abcb1309e9bb2'
    })
  end,
}
