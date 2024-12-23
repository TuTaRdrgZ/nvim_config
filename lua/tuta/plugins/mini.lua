vim.cmd([[
  augroup MiniStarterJK
    au!
    au User MiniStarterOpened nmap <buffer> j <Cmd>lua MiniStarter.update_current_item('next')<CR>
    au User MiniStarterOpened nmap <buffer> k <Cmd>lua MiniStarter.update_current_item('prev')<CR>
    au User MiniStarterOpened nmap <buffer> <C-p> <Cmd>Telescope find_files<CR>
    au User MiniStarterOpened nmap <buffer> <C-n> <Cmd>Telescope file_browser<CR>
  augroup END
  ]])
return {

	{
		"echasnovski/mini.nvim",
		version = false,
		config = function()
			-- Improved editing experience
			require("mini.ai").setup()
			require("mini.pairs").setup()
			require("mini.comment").setup()
			require("mini.surround").setup()
			require("mini.bufremove").setup()
			-- UI/UX
			require("mini.statusline").setup()
			require("mini.tabline").setup()
			require("mini.cursorword").setup()
			require("mini.icons").setup()
			require("mini.starter").setup({
				-- header = "⚡ Neovim",
			})
		end,
	},
}
