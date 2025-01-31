-- import telescope plugin safely
local telescope_setup, telescope = pcall(require, "telescope")
if not telescope_setup then
	return
end

-- import telescope actions safely
local actions_setup, actions = pcall(require, "telescope.actions")
if not actions_setup then
	return
end

-- configure telescope
local fb_actions = require("telescope._extensions.file_browser.actions")

telescope.setup({
	defaults = {
		mappings = {
			i = {
				["<C-k>"] = actions.move_selection_previous, -- move to prev result
				["<C-j>"] = actions.move_selection_next, -- move to next result
				["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- send selected to quickfixlist
			},
		},
		theme = "center",
		sorting_strategy = "ascending",
		layout_config = {
			horizontal = {
				prompt_position = "top",
				preview_width = 0.4,
			},
		},
	},
	-- pickers = {
	-- 	find_files = {
	-- 		hidden = true,
	-- 	},
	-- },
	extensions = {
		file_browser = {
			cwd_to_path = false,
			grouped = false,
			files = true,
			add_dirs = true,
			depth = 2,
			auto_depth = true,
			select_buffer = false,
			hidden = { file_browser = true, folder_browser = true },
			respect_gitignore = vim.fn.executable("fd") == 1,
			no_ignore = false,
			follow_symlinks = false,
			browse_files = require("telescope._extensions.file_browser.finders").browse_files,
			browse_folders = require("telescope._extensions.file_browser.finders").browse_folders,
			hide_parent_dir = false,
			collapse_dirs = false,
			prompt_path = false,
			quiet = false,
			dir_icon = "",
			dir_icon_hl = "Default",
			display_stat = { date = true, size = true, mode = true },
			use_fd = true,
			git_status = true,
			-- disables netrw and use telescope-file-browser in its place
			hijack_netrw = true,
			mappings = {
				["i"] = {
					-- your custom insert mode mappings
				},
				["n"] = {
					["c"] = fb_actions.create,
					["r"] = fb_actions.rename,
					["m"] = fb_actions.move,
					["y"] = fb_actions.copy,
					["d"] = fb_actions.remove,
					["o"] = fb_actions.open,
					["g"] = fb_actions.goto_parent_dir,
					["e"] = fb_actions.goto_home_dir,
					["w"] = fb_actions.goto_cwd,
					["t"] = fb_actions.change_cwd,
					["f"] = fb_actions.toggle_browser,
					["h"] = fb_actions.toggle_hidden,
					["s"] = fb_actions.toggle_all,
				},
			},
		},
	},
})

local harpoon = require("harpoon")

-- basic telescope configuration
local conf = require("telescope.config").values
-- local function toggle_telescope(harpoon_files)
-- 	local file_paths = {}
-- 	for _, item in ipairs(harpoon_files.items) do
-- 		table.insert(file_paths, item.value)
-- 	end
--
-- 	require("telescope.pickers")
-- 		.new({}, {
-- 			prompt_title = "Harpoon",
-- 			finder = require("telescope.finders").new_table({
-- 				results = file_paths,
-- 			}),
-- 			previewer = conf.file_previewer({}),
-- 			sorter = conf.generic_sorter({}),
-- 		})
-- 		:find()
-- end

local function toggle_telescope(harpoon_files)
	local finder = function()
		local paths = {}
		for _, item in ipairs(harpoon_files.items) do
			table.insert(paths, item.value)
		end

		return require("telescope.finders").new_table({
			results = paths,
		})
	end

	require("telescope.pickers")
		.new({}, {
			prompt_title = "Harpoon",
			finder = finder(),
			-- previewer = false,
			-- sorter = require("telescope.config").values.generic_sorter({}),
			previewer = conf.file_previewer({}),
			sorter = conf.generic_sorter({}),
			layout_config = {
				height = 0.4,
				width = 0.6,
				prompt_position = "top",
				-- preview_cutoff = 20,
				preview_width = 60,
			},
			attach_mappings = function(prompt_bufnr, map)
				map("n", "<C-d>", function()
					local state = require("telescope.actions.state")
					local selected_entry = state.get_selected_entry()
					local current_picker = state.get_current_picker(prompt_bufnr)

					table.remove(harpoon_files.items, selected_entry.index)
					current_picker:refresh(finder())
				end)
				return true
			end,
		})
		:find()
end

vim.keymap.set("n", "<C-e>", function()
	toggle_telescope(harpoon:list())
end, { desc = "Open harpoon window" })

telescope.load_extension("fzf")
-- To get telescope-file-browser loaded and working with telescope,
-- you need to call load_extension, somewhere after setup function:
telescope.load_extension("file_browser")

-- to open file browser by default
local function open_file_browser(data)
	-- buffer is a [No Name]
	local no_name = data.file == "" and vim.bo[data.buf].buftype == ""

	-- buffer is a directory
	local directory = vim.fn.isdirectory(data.file) == 1

	if not no_name and not directory then
		return
	end

	-- change to the directory
	if directory then
		vim.cmd.cd(data.file)
	end

	-- if harpoon:list() ~= "" then
	-- 	toggle_telescope(harpoon:list())
	-- 	return
	-- end

	-- open the tree
	telescope.extensions.file_browser.file_browser()
end

vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_file_browser })

vim.keymap.set("n", "<C-e>", function()
	toggle_telescope(harpoon:list())
end, { desc = "Open harpoon window" })
