local oil = require("oil")

oil.setup({
	-- nuke netrw
	default_file_explorer = true,

	columns = {
		"icon",
	},

	win_options = {
		wrap = false,
	},

	use_default_keymaps = false,
	keymaps = {
		["<CR>"] = "actions.select",
		["-"] = { "actions.parent", mode = "n" },
	},
})

vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", {
	desc = "open file browser",
})
