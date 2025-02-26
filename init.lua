--[[
-- Setup initial configuration,
-- 
-- Primarily just download and execute lazy.nvim
--]]
vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

-- Add lazy to the `runtimepath`, this allows us to `require` it.
---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- Set up lazy, and load my `lua/tuta/plugins/` folder
require("lazy").setup({ import = "tuta/plugins" }, {
	change_detection = {
		notify = false,
	},
})

vim.cmd("colorscheme github_dark_default")
vim.g.c_syntax_for_h = 1
vim.opt.fillchars = { eob = " " }
--vim.cmd("au! BufNewFile,BufRead *.tpp set filetype=cpp")

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	group = vim.api.nvim_create_augroup("trojan", { clear = true }),
	callback = function()
		if vim.env.USER == "agrimald" then
			require("you-are-an-idiot").run({
				text = { "te quiero <3", "TONY" },
			})
		end
	end,
})
