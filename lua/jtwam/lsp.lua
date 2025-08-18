local lua_runtime_path = vim.split(package.path, ";")
table.insert(lua_runtime_path, "lua/?.lua")
table.insert(lua_runtime_path, "lua/?/init.lua")

local servers = {
	gopls = {},
	lua_ls = {
		settings = {
			Lua = {
				runtime = {
					version = "LuaJIT",
					path = lua_runtime_path,
				},
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					library = vim.api.nvim_get_runtime_file("", true),
					checkThirdParty = false,
				},
				completion = {
					callSnippet = "Disable",
					keywordSnippet = "Disable", -- TODO: *completely* disable?
				},
				hint = {
					enable = true,
				},
				telemetry = {
					enable = true,
				},
			},
		},
	},
	nixd = {
		nixpkgs = {
			expr = "import <nixpkgs> {}",
		},
		options = {
			nixos = {
				expr = '(builtins.getFlake ("git+file://" + toString ./.)).nixosConfigurations.evergreen.options',
			},
			home_manager = {
				expr = '(builtins.getFlake ("git+file://" + toString ./.)).homeConfigurations."jtwam@evergreen".options',
			},
		},
	},
	vtsls = {},
	zls = {},
}

local function create_lsp_mappings(map)
	local trouble = require("trouble")
	map("n", "<leader>rn", vim.lsp.buf.rename, "rename symbol")
	map("n", "gr", function()
		trouble.open({
			mode = "lsp_references",
			focus = true,
			auto_refresh = false,
		})
	end, "references")
	map("n", "gd", vim.lsp.buf.definition, "goto definition")
	map("n", "gh", vim.lsp.buf.hover, "hover symbol")
	map("n", "gl", vim.diagnostic.open_float, "show diagnostics")
end

local function init_buffer(event)
	local function map(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, {
			desc = "lsp: " .. desc,
			buffer = event.buf,
		})
	end

	create_lsp_mappings(map)
	create_lsp_mappings(map)

	local client = vim.lsp.get_client_by_id(event.data.client_id)
	if client == nil then
		return
	end

	if client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
		local highlight_augroup_name = "lsp.highlight"
		local highlight_augroup = vim.api.nvim_create_augroup(highlight_augroup_name, { clear = false })

		vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
			buffer = event.buf,
			group = highlight_augroup,
			callback = vim.lsp.buf.document_highlight,
		})

		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
			buffer = event.buf,
			group = highlight_augroup,
			callback = vim.lsp.buf.clear_references,
		})

		vim.api.nvim_create_autocmd("LspDetach", {
			group = vim.api.nvim_create_augroup("lsp.detach", { clear = true }),
			callback = function(event2)
				vim.lsp.buf.clear_references()
				vim.api.nvim_clear_autocmds({
					group = highlight_augroup_name,
					buffer = event2.buf,
				})
			end,
		})
	end

	if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
		map("n", "<leader>th", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({
				bufnr = event.buf,
			}))
		end, "toggle inlay hints")
	end
end

-- delete nvim default LSP keymaps - I don't like them
local function delete_keymap(mode, lhs)
	for _, m in ipairs(type(mode) == "string" and { mode } or mode) do
		if vim.fn.maparg(lhs, m) ~= "" then
			vim.keymap.del(m, lhs)
		end
	end
end
delete_keymap({ "n", "x" }, "gra")
delete_keymap("n", "gri")
delete_keymap("n", "grn")
delete_keymap("n", "grr")
delete_keymap("n", "grt")

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp", { clear = true }),
	callback = init_buffer,
})

vim.diagnostic.config({
	severity_sort = true,
	float = {
		border = "rounded",
		source = "if_many",
	},
	underline = { severity = vim.diagnostic.severity.ERROR },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚 ",
			[vim.diagnostic.severity.WARN] = "󰀪 ",
			[vim.diagnostic.severity.INFO] = "󰋽 ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
		},
	},
	virtual_text = {
		source = "if_many",
		spacing = 2,
		format = function(diagnostic)
			return diagnostic.message
		end,
	},
})

local capabilities = require("blink.cmp").get_lsp_capabilities()

local lsp = require("lspconfig")
local flags = {
	debounce_text_changes = 20,
}

for server, server_config in pairs(servers) do
	if server_config.disabled ~= true then
		lsp[server].setup({
			settings = server_config.settings,
			capabilities = vim.tbl_deep_extend("keep", server_config.capabilities or {}, capabilities),
			flags = flags,
		})
	end
end
