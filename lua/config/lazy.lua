-- Funzione per gestire il percorso del lockfile con nixCats
local function getlockfilepath()
  if require('nixCatsUtils').isNixCats and nixCats.settings and type(nixCats.settings.unwrappedCfgPath) == 'string' then
    return nixCats.settings.unwrappedCfgPath .. '/lazy-lock.json'
  else
    return vim.fn.stdpath 'config' .. '/lazy-lock.json'
  end
end

local lazyOptions = {
  lockfile = getlockfilepath(),
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘', config = '🛠', event = '📅', ft = '📂', init = '⚙', keys = '🗝', plugin = '🔌', 
      runtime = '💻', require = '🌙', source = '📄', start = '🚀', task = '📌', lazy = '💤 ',
    },
  },
}

-- 2. Imposta la Leader Key prima di caricare lazy
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- 3. Imposta se abbiamo una Nerd Font (usando nixCats)
vim.g.have_nerd_font = nixCats('have_nerd_font')

-- Configurazione e installazione dei plugin TRAMITE IL WRAPPER NIXCATS.
-- Ora che il flake.nix è corretto, questo funzionerà come previsto.
require('nixCatsUtils.lazyCat').setup(
  nixCats.pawsible { 'allPlugins', 'start', 'lazy.nvim' }, -- Trova lazy.nvim da Nix
  {
    -- Importa tutto ciò che si trova in lua/plugins/*.lua come una lista di specifiche
    { import = 'plugins' },
  },
  lazyOptions
)
