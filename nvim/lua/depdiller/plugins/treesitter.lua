-- import nvim-treesitter plugin safely
local status, treesitter = pcall(require, "nvim-treesitter.configs")
if not status then
	return
end

-- configure treesitter
treesitter.setup({
	ensure_installed = {
		"csv",
		"dockerfile",
		"gitignore",
		"go",
		"gomod",
		"gosum",
		"gowork",
		"javascript",
		"json",
		"lua",
		"markdown",
		"proto",
		"python",
		"rego",
		"ruby",
		"sql",
		"svelte",
		"yaml",
		"php",
	},
	indent = { enable = true },
	auto_install = true,
	sync_install = false,
	highlight = {
		enable = true,
	},
	textobjects = { select = { enable = true, lookahead = true } },
})
