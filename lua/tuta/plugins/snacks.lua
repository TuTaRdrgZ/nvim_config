return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			statuscolumn = { enabled = false },
			quickfile = { enabled = false },
			rename = { enabled = false },
			bufdelete = { enabled = false },
			terminal = {
				enabled = true,
				win = {
					position = "float",
					border = "single",
				},
			},
			words = {
				enabled = true,
				debounce = 200,
				notify_jump = false,
				notify_end = true,
				foldopen = true,
				jumplist = true,
				modes = { "n" },
			},
		},
		-- keys = {
		-- 	{
		-- 		"<leader>lg",
		-- 		function()
		-- 			Snacks.lazygit()
		-- 		end,
		-- 		desc = "Lazygit",
		-- 	},
		-- 	{
		-- 		"<leader>gB",
		-- 		function()
		-- 			Snacks.gitbrowse()
		-- 		end,
		-- 		desc = "Git Browse",
		-- 	},
		-- 	{
		-- 		"<leader>gf",
		-- 		function()
		-- 			Snacks.lazygit.log_file()
		-- 		end,
		-- 		desc = "Lazygit Current File History",
		-- 	},
		-- 	{
		-- 		"<leader>gl",
		-- 		function()
		-- 			Snacks.lazygit.log()
		-- 		end,
		-- 		desc = "Lazygit Log (cwd)",
		-- 	},
		-- 	{
		-- 		"<c-t>",
		-- 		function()
		-- 			Snacks.terminal.toggle()
		-- 		end,
		-- 		desc = "Toggle Terminal",
		-- 	},
		-- 	{
		-- 		"]]",
		-- 		function()
		-- 			Snacks.words.jump(vim.v.count1)
		-- 		end,
		-- 		desc = "Next Reference",
		-- 	},
		-- 	{
		-- 		"[[",
		-- 		function()
		-- 			Snacks.words.jump(-vim.v.count1)
		-- 		end,
		-- 		desc = "Prev Reference",
		-- 	},
		-- },
		-- sections = {
		-- 	{ section = "header" },
		-- 	{ icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
		-- 	{ icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
		-- 	{ icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
		-- 	{ section = "startup" },
		-- },
	},
}
