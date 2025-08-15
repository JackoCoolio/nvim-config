local trouble = require("trouble")

trouble.setup({
	auto_close = true,
	auto_refresh = false, -- I hate this.
	follow = false,

	modes = {
		diagnostics = {
			auto_open = true,
		},
		lsp_references = {
			focus = true,
		},
	},
})

vim.keymap.set("n", "<leader>dc", function()
	trouble.close()
end, { desc = "diag: toggle diagnostics" })
