return {
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- signs = { add = { text = '+' }, change = { text = '~' }, delete = { text = '_' }, topdelete = { text = '‾' }, changedelete = { text = '~' }, },
    },
  },

  {
    -- Highlight todo, notes, etc in comments
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false }
  },

  {
    "j-hui/fidget.nvim",
    opts = { }
  },

  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- adds type hints for nixCats global
        { path = (nixCats.nixCatsPath or '') .. '/lua', words = { 'nixCats' } },
      },
    },
  },

  {
    'APZelos/blamer.nvim',
    enable = true,
    lazy = false,
  },

  {
    'nvim-lua/popup.nvim',
    enable = true,
    lazy = false,
  },

  {
    'nvim-pack/nvim-spectre',
    enable = true,
    lazy = false,
  },

  {
    'mbbill/undotree',
    enable = true,
    lazy = false,
  },
  


}
