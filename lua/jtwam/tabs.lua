-- Defines default tab stop configuration.

local default_width = 4
local default_expand = true

local lang_config = {
	nix = 2,
	lua = { 4, expand = false },
}

local function set_tab_config(o, config)
	local width = nil
	if type(config) == "number" then
		width = config
		config = {}
	elseif type(config) == "table" then
		width = (config[1] == nil and default_width) or config[1]
	else
		error("invalid tab configuration")
	end

	o.tabstop = width
	o.shiftwidth = width
	o.expandtab = (config.expand == nil and default_expand) or config.expand
	o.softtabstop = width
end

vim.api.nvim_create_augroup("tabs", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		if lang_config[args.match] == nil then
			return
		end
		set_tab_config(vim.bo, lang_config[args.match])
	end,
	group = "tabs",
})

set_tab_config(vim.go, { default_width, expand = default_expand })
