local fzf = require("fzf-lua")
local color = require("jtwam.color")

-- files that I *never* want to fuzzy-find for
local exclusions = {
	".direnv",
	".jj",
	".git",
	".zig-cache",
	"result", -- nix derivation output
}

local fd_opts = { "--type f" }
for _, file in ipairs(exclusions) do
	table.insert(fd_opts, "--exclude " .. file)
end

local builtin_colorschemes = vim.iter(color.get_builtin_colorschemes())
	:filter(function(cs)
		-- default is okay. it can stay :)
		return cs ~= "default"
	end)
	:map(function(cs)
		return "^" .. cs .. "$"
	end)
	:totable()

fzf.setup({
	"ivy",
	files = {
		hidden = false,
		follow = false,
		formatter = "path.filename_first",
		fd_opts = table.concat(fd_opts, " "),
	},
	colorschemes = {
		-- ignore builtin colorschemes
		ignore_patterns = builtin_colorschemes,
	},
})

vim.keymap.set("n", "<leader>ff", function()
	require("fzf-lua").files()
end, { desc = "fzf: open file" })

vim.keymap.set("n", "<leader>fd", function()
	fzf.lsp_document_symbols()
end, { desc = "fzf: goto document symbol" })

vim.keymap.set("n", "<leader>fw", function()
	fzf.lsp_document_symbols()
end, { desc = "fzf: goto workspace symbol" })

vim.keymap.set("n", "<leader>fc", function()
	fzf.colorschemes()
end, { desc = "fzf: choose colorscheme" })
