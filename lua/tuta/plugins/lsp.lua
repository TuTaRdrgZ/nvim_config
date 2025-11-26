local capabilities = vim.lsp.protocol.make_client_capabilities()
if pcall(require, "blink.cmp") then
	capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
end

capabilities.offsetEncoding = { "utf-16" }

return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"folke/lazydev.nvim",
			{ "Bilal2453/luvit-meta", lazy = true },
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			{ "https://git.sr.ht/~whynothugo/lsp_lines.nvim" },
			"stevearc/conform.nvim",
			"b0o/SchemaStore.nvim",
		},
		config = function()
			if vim.g.obsidian then
				return
			end

			local extend = function(name, key, values)
				local mod = require(string.format("lspconfig.configs.%s", name))
				local default = mod.default_config
				local keys = vim.split(key, ".", { plain = true })
				while #keys > 0 do
					local item = table.remove(keys, 1)
					default = default[item]
				end
				if vim.islist(default) then
					for _, value in ipairs(default) do
						table.insert(values, value)
					end
				else
					for item, value in pairs(default) do
						if not vim.tbl_contains(values, item) then
							values[item] = value
						end
					end
				end
				return values
			end

			local servers = {
				lua_ls = {
					server_capabilities = { semanticTokensProvider = vim.NIL },
				},
				ts_ls = {
					root_dir = require("lspconfig.util").root_pattern("package.json"), -- Nota: require directo a util
					single_file = false,
					server_capabilities = { documentFormattingProvider = false },
				},
				clangd = {
					init_options = {
						clangdFileStatus = true,
						completeUnimported = true,
						documentFormattingProvider = false,
						documentRangeFormattingProvider = false,
					},
					cmd = { "clangd", "--background-index", "--clang-tidy", "--offset-encoding=utf-16" },
					root_dir = require("lspconfig.util").root_pattern("compile_commands.json", ".git"),
					filetypes = { "c", "h", "cpp", "hpp" },
				},
				tailwindcss = {
					init_options = {
						userLanguages = { eruby = "erb", heex = "phoenix-heex" },
					},
					filetypes = extend("tailwindcss", "filetypes", { "ocaml.mlx" }),
					settings = {
						tailwindCSS = {
							experimental = {
								classRegex = {
									[[class: "([^"]*)]],
									[[className="([^"]*)]],
								},
							},
							includeLanguages = extend("tailwindcss", "settings.tailwindCSS.includeLanguages", {
								["ocaml.mlx"] = "html",
							}),
						},
					},
				},
				cssls = {
					settings = { css = { validate = true } },
				},
				html = { filetypes = { "html", "htm" } },
			}

			require("mason").setup()
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, { "stylua" })
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local opts = servers[server_name] or {}

						opts.capabilities = vim.tbl_deep_extend("force", {}, capabilities, opts.capabilities or {})

						local ok, config_module = pcall(require, "lspconfig.configs." .. server_name)
						local default_config = {}
						if ok and config_module then
							default_config = config_module.default_config
						end

						local final_config = vim.tbl_deep_extend("force", default_config, opts)

						vim.lsp.config[server_name] = final_config

						vim.lsp.enable(server_name)
					end,
				},
			})

			local disable_semantic_tokens = {
				lua = true,
			}

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local bufnr = args.buf
					local client = assert(vim.lsp.get_client_by_id(args.data.client_id), "must have valid client")

					local settings = servers[client.name]
					if type(settings) ~= "table" then
						settings = {}
					end

					local builtin = require("telescope.builtin")

					vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
					vim.keymap.set("n", "gd", builtin.lsp_definitions, { buffer = 0 })
					vim.keymap.set("n", "gr", builtin.lsp_references, { buffer = 0 })
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = 0 })
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = 0 })
					vim.keymap.set("n", "gT", vim.lsp.buf.type_definition, { buffer = 0 })
					vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = 0 })

					vim.keymap.set("n", "<space>cr", vim.lsp.buf.rename, { buffer = 0 })
					vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, { buffer = 0 })
					vim.keymap.set("n", "<space>wd", builtin.lsp_document_symbols, { buffer = 0 })

					local filetype = vim.bo[bufnr].filetype
					if disable_semantic_tokens[filetype] then
						client.server_capabilities.semanticTokensProvider = nil
					end

					if settings.server_capabilities then
						for k, v in pairs(settings.server_capabilities) do
							if v == vim.NIL then
								---@diagnostic disable-next-line: cast-local-type
								v = nil
							end
							client.server_capabilities[k] = v
						end
					end
				end,
			})

			require("tuta.autoformat").setup()
			require("lsp_lines").setup()
			vim.diagnostic.config({ virtual_text = true, virtual_lines = false })

			vim.keymap.set("", "<leader>d", function()
				local config = vim.diagnostic.config() or {}
				if config.virtual_text then
					vim.diagnostic.config({ virtual_text = false, virtual_lines = true })
				else
					vim.diagnostic.config({ virtual_text = true, virtual_lines = false })
				end
			end, { desc = "Toggle lsp_lines" })
		end,
	},
}
