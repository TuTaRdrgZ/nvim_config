local setup = function()
	-- Autoformatting Setup
	local conform = require("conform")
	conform.setup({
		formatters = {
			c_formatter_42 = {
				command = "c_formatter_42",
				args = { "$FILENAME" },
				stdin = false,
			},
		},
		formatters_by_ft = {
			lua = { "stylua" },
			c = { "c_formatter_42" },
		},
	})

	vim.api.nvim_create_autocmd("BufWritePre", {
		group = vim.api.nvim_create_augroup("custom-conform", { clear = true }),
		callback = function(args)
			local ft = vim.bo[args.buf].filetype

			if ft == "c" or ft == "h" then
				require("conform").format({
					bufnr = args.buf,
					formatters = { "c_formatter_42" },
					lsp_fallback = false,
				})
				return
			end

			require("conform").format({
				bufnr = args.buf,
				lsp_fallback = true,
				quiet = true,
			})
		end,
	})
end

setup()

return { setup = setup }
