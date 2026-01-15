return {
    'nvim-treesitter/nvim-treesitter',
    
    name = 'nvim-treesitter',

    lazy = false,

    config = function()
        require('nvim-treesitter.configs').setup({
            -- IMPORTANTE: su NixOS questi devono essere false
            highlight = { enable = true },
            indent = { enable = true },
            ensure_installed = {}, -- Lascia vuoto, ci pensa Nix!
        })
    end
}
