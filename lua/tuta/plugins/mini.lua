return {
	{
		'echasnovski/mini.nvim', version = false,
		config = function()
			-- Improved editing experience
			require('mini.ai').setup()
			require('mini.pairs').setup()
			require('mini.comment').setup()
			require('mini.surround').setup()
			require('mini.bufremove').setup()
			-- UI/UX
			require('mini.statusline').setup()
			require('mini.tabline').setup()
			require('mini.cursorword').setup()
			require('mini.icons').setup()
		end
	},
}
