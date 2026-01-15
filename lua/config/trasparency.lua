vim.cmd [[
hi Normal guibg=NONE ctermbg=NONE
hi NormalFloat guibg=NONE ctermbg=NONE
hi FloatBorder guibg=NONE ctermbg=NONE
hi FloatShadow guibg=NONE ctermbg=NONE

hi Comment guibg=NONE ctermbg=NONE 
hi NormalNC guibg=NONE ctermbg=NONE 
hi Constant guibg=NONE ctermbg=NONE 
hi Special guibg=NONE ctermbg=NONE 
hi Identifier guibg=NONE ctermbg=NONE 
hi Statement guibg=NONE ctermbg=NONE
hi EndOfBuffer guibg=NONE ctermbg=NONE 
hi ColorColumn guibg=NONE ctermfg=NONE 

hi Pmenu guibg=NONE ctermbg=NONE
hi PmenuBorder guibg=NONE ctermbg=NONE
hi FidgetNormal guibg=NONE ctermbg=NONE
]]
vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE", ctermbg = "NONE" })
vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE", ctermbg = "NONE" })
