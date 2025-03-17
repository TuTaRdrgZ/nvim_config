local autoformat_enabled = true

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
			-- Solo se formatea si autoformat_enabled es true
			if not autoformat_enabled then
				return
			end

			local ft = vim.bo[args.buf].filetype

			if ft == "c" or ft == "h" then
				-- Para archivos .c y .h, usa sólo el formateador personalizado
				require("conform").format({
					bufnr = args.buf,
					formatters = { "c_formatter_42" },
					lsp_fallback = false, -- No queremos usar LSP fallback aquí
				})
				return
			end

			-- Para otros tipos de archivo (por ejemplo, cpp se formatea con clangd vía LSP)
			require("conform").format({
				bufnr = args.buf,
				lsp_fallback = true,
				quiet = true,
			})
		end,
	})

	-- Keybinding para alternar (toggle) el autoformatter (modo normal: "space" + "tf")
	vim.keymap.set("n", "<space>tf", function()
		autoformat_enabled = not autoformat_enabled
		if autoformat_enabled then
			print("Autoformatter activado")
		else
			print("Autoformatter desactivado")
		end
	end, { desc = "Toggle autoformatter" })
end

setup()

return { setup = setup }
