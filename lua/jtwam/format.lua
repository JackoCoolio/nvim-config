local conform = require("conform")

conform.setup({
	formatters_by_ft = {
		lua = { "treefmt", "stylua" },
		rust = { "treefmt", "rustfmt" },
		nix = { "treefmt" },
	},

	default_format_opts = {
		stop_after_first = true,
	},

	format_on_save = {
		lsp_format = "fallback",
		timeout_ms = 500,
	},
})
