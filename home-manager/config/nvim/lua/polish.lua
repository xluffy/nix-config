-- This runs last in the setup process, after all plugins (including AstroCore).
-- Use this for final-say overrides that plugin defaults may stomp on.

-- Soft wrapping for readable prose (overrides AstroCore's default wrap=false)
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.showbreak = "↪ "
