local blink = require("blink.cmp")

blink.setup({
	keymap = {
		preset = "none",

		["<CR>"] = { "accept", "fallback" },
		["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },

		["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
		["<Down>"] = { "select_next", "snippet_forward", "fallback" },

		["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
		["<Up>"] = { "select_prev", "snippet_backward", "fallback" },
	},

	appearance = {
		use_nvim_cmp_as_default = true,
		nerd_font_variant = "normal",
	},

	sources = {
		default = {
			"lsp",
			"path",
			"buffer",
		},
	},

	completion = {
		list = {
			selection = {
				preselect = false,
				auto_insert = false,
			},
		},
		ghost_text = {
			enabled = false,
		},
		menu = {
			draw = {
				treesitter = { "lsp" },
			},
		},
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 100,
		},
	},

	fuzzy = {
		implementation = "prefer_rust",
	},
})
