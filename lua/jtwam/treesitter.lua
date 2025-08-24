require("nvim-treesitter.configs").setup({
	-- installed grammars
	ensure_installed = {}, -- prevent treesitter from trying to install them itself
	sync_install = false,
	auto_install = false,
	ignore_install = {},

	highlight = {
		enable = true,
	},

	indent = {
		enable = true,
	},

	modules = {},
})
