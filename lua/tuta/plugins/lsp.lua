local capabilities = vim.lsp.protocol.make_client_capabilities()
if pcall(require, "blink.cmp") then
	capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
end

capabilities.offsetEncoding = { "utf-16" }

return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
				-- used for completion, annotations and signatures of Neovim apis
				"folke/lazydev.nvim",
				ft = "lua",
				opts = {
					library = {
						-- Load luvit types when the `vim.uv` word is found
						{ path = "luvit-meta/library", words = { "vim%.uv" } },
					},
				},
			},
			{ "Bilal2453/luvit-meta", lazy = true },
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			{ "j-hui/fidget.nvim", opts = {} },
			{ "https://git.sr.ht/~whynothugo/lsp_lines.nvim" },

			-- Autoformatting
			"stevearc/conform.nvim",

			-- Schema information
			"b0o/SchemaStore.nvim",
		},
		config = function()
			-- Don't do LSP stuff if we're in Obsidian Edit mode
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

			local capabilities = nil
			if pcall(require, "blink.cmp") then
				capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
			end

			local lspconfig = require("lspconfig")

			local servers = {
				lua_ls = {
					server_capabilities = {
						semanticTokensProvider = vim.NIL,
					},
				},
				ts_ls = {
					root_dir = require("lspconfig").util.root_pattern("package.json"),
					single_file = false,
					server_capabilities = {
						documentFormattingProvider = false,
					},
				},
				-- gopls = {
				-- 	settings = {
				-- 		gopls = {
				-- 			hints = {
				-- 				assignVariableTypes = true,
				-- 				compositeLiteralFields = true,
				-- 				compositeLiteralTypes = true,
				-- 				constantValues = true,
				-- 				functionTypeParameters = true,
				-- 				parameterNames = true,
				-- 				rangeVariableTypes = true,
				-- 			},
				-- 		},
				-- 	},
				-- },

				clangd = {
					capabilities = capabilities,
					init_options = {
						clangdFileStatus = true, -- Muestra el estado del archivo en el workspace
						completeUnimported = true, -- Autocompletado de cabeceras no incluidas
						documentFormattingProvider = false,
						documentRangeFormattingProvider = false,
					},
					cmd = { "clangd", "--background-index", "--clang-tidy", "--offset-encoding=utf-16" },
					root_dir = lspconfig.util.root_pattern("compile_commands.json", ".git"),

					filetypes = { "c", "h", "cpp", "hpp" },
				},

				tailwindcss = {
					init_options = {
						userLanguages = {
							eruby = "erb",
							heex = "phoenix-heex",
						},
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
					capabilities = capabilities,
					settings = {
						css = {
							validate = true,
						},
					},
				},
				html = {
					capabilities = capabilities,
					filetypes = { "html", "htm" },
				},
			}

			local servers_to_install = vim.tbl_filter(function(key)
				local t = servers[key]
				if type(t) == "table" then
					return not t.manual_install
				else
					return t
				end
			end, vim.tbl_keys(servers))

			require("mason").setup()
			local ensure_installed = {
				"stylua",
				"lua_ls",
				"clangd",
				-- "tailwind-language-server",
			}

			vim.list_extend(ensure_installed, servers_to_install)
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			for name, config in pairs(servers) do
				if config == true then
					config = {}
				end
				config = vim.tbl_deep_extend("force", {}, {
					capabilities = capabilities,
				}, config)

				lspconfig[name].setup(config)
			end

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

					-- Override server capabilities
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
