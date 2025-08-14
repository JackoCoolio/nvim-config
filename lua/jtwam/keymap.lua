-- General keymaps - shouldn't be directly related to a plugin.

-- prevent cursor from jumping in some cases:
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- bad times ahead if press Q
vim.keymap.set("n", "Q", "<nop>")

-- source
vim.keymap.set("n", "<leader>so", ":update | source<CR>")

-- write
vim.keymap.set("n", "<leader>w", ":write<CR>")
