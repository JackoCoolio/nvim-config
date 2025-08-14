local M = {}

local last_colorscheme_path = vim.fn.stdpath("data") .. "/last-color"

--- Returns the most recently-set colorscheme.
M.get_last_colorscheme = function()
	local file = io.open(last_colorscheme_path, "r")
	if file == nil then
		-- no colorscheme saved
		return nil
	end

	local colorscheme = file:read("*a")
	file:close()
	if #colorscheme == 0 then
		-- empty file
		return nil
	end

	return colorscheme
end

M.set_last_colorscheme = function(colorscheme)
	local file, err = io.open(last_colorscheme_path, "w+")
	if file == nil then
		error("failed to open last-colorscheme file: " .. err)
		return
	end

	file:write(colorscheme)
	file:close()
end

M.get_builtin_colorschemes = function()
	local runtime_colors = vim.api.nvim_get_runtime_file("colors/*.{vim,lua}", true)
	local builtins = {}

	for _, path in ipairs(runtime_colors) do
		if path:match("/share/nvim/runtime/colors/") then
			local name = vim.fn.fnamemodify(path, ":t:r")
			table.insert(builtins, name)
		end
	end

	return builtins
end

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("colorscheme", { clear = true }),
	callback = function(event)
		local colorscheme = event.match
		M.set_last_colorscheme(colorscheme)
	end,
})

local last_colorscheme = M.get_last_colorscheme()
if last_colorscheme ~= nil then
	vim.cmd("colorscheme " .. last_colorscheme)
end

return M
