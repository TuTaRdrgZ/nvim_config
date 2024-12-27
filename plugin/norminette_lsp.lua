local client = vim.lsp.start_client({
	name = "norminette_lsp",
	cmd = { "/home/tuta/tuta/coding/randomProjects/lsp/norminette-lsp-cpp/NLSP" },
	on_attach = function()
		local builtin = require("telescope.builtin")
		vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
		vim.keymap.set("n", "gd", builtin.lsp_definitions, { buffer = 0 })
		vim.keymap.set("n", "gr", builtin.lsp_references, { buffer = 0 })
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = 0 })
		vim.keymap.set("n", "gT", vim.lsp.buf.type_definition, { buffer = 0 })
		vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = 0 })

		vim.keymap.set("n", "<space>cr", vim.lsp.buf.rename, { buffer = 0 })
		vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, { buffer = 0 })
		vim.keymap.set("n", "<space>wd", builtin.lsp_document_symbols, { buffer = 0 })
	end,
})

if not client then
	vim.notify("Failed to start norminette_lsp")
	return
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "h", "c" },

	callback = function()
		vim.lsp.buf_attach_client(0, client)
	end,
})
