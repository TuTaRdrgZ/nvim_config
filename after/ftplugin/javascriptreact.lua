-- ~/.config/nvim/ftplugin/javascriptreact.lua

vim.bo.shiftwidth = 2
vim.bo.tabstop = 2
vim.bo.softtabstop = 2
vim.bo.expandtab = true
vim.g.jsx_indent_enable = 1
vim.g.jsx_indent_inner_html = 1

vim.cmd("setlocal indentexpr=")
vim.cmd("setlocal smartindent")

vim.cmd("setlocal formatoptions+=cro")

vim.api.nvim_buf_set_keymap(
	0,
	"n",
	"<leader>cf",
	"<cmd>silent !prettier --write % > /dev/null 2>&1<cr>",
	{ noremap = true, silent = true, desc = "format code with prettier" }
)

if pcall(require, "nvim-treesitter.configs") then
	require("nvim-treesitter.configs").setup({
		highlight = { enable = true },
		indent = { enable = true },
		ensure_installed = { "javascript", "tsx", "html" },
	})
end

local lspconfig = require("lspconfig")
if lspconfig.ts_ls then
	lspconfig.ts_ls.setup({
		on_attach = function(client, bufnr)
			local opts = { noremap = true, silent = true }
			vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>c", ":lua vim.lsp.buf.format()<CR>", opts)
		end,
	})
end

vim.cmd("setlocal noautoindent")
vim.cmd("setlocal smartindent")
