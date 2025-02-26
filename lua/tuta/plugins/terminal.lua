return {
	"folke/snacks.nvim",
	opts = {
		terminal = {
			enabled = true,
			-- your terminal configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
	},
	vim.keymap.set({ "n", "i", "t" }, "<c-\\>", function()
		Snacks.terminal()
	end, { desc = "Toggle Terminal" }),
}
