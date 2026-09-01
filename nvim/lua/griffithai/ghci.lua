--[[ ghci in a split to the right ]]--
-- Keeps one repl terminal per project and sends `:load` to it, so the split is
-- reused instead of a new repl being spawned on every call.

local M = {}

-- Fallback for a loose .hs file that belongs to no project.
M.cmd = "ghci"

local state = { buf = nil, chan = nil, root = nil }

local function alive()
	return state.buf ~= nil and vim.api.nvim_buf_is_valid(state.buf)
end

local function window_showing(buf)
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == buf then
			return win
		end
	end
end

-- Where to start the repl, and with what.
--
-- A bare `ghci` rooted at the file's own directory cannot see sibling modules
-- (src/APL/Eval.hs importing APL.AST needs src/ on the search path, not
-- src/APL/) and knows nothing about build-depends. So when the file belongs to
-- a project, hand off to the build tool's own repl from the project root and
-- let it set -i and the package environment.
local function repl_for(dir)
	local function up(names)
		local hit = vim.fs.find(names, { path = dir, upward = true, type = "file" })[1]
		return hit and vim.fs.dirname(hit) or nil
	end

	local stack = up({ "stack.yaml" })
	if stack then
		return stack, "stack ghci"
	end

	local cabal = up(function(name)
		return name:match("%.cabal$") ~= nil or name == "cabal.project"
	end)
	if cabal then
		return cabal, "cabal repl"
	end

	return dir, M.cmd
end

-- Make sure a repl exists for `root` and is visible in the rightmost column.
-- The cursor stays in the window it started in.
local function ensure_repl(root, cmd)
	local cur = vim.api.nvim_get_current_win()

	-- A repl from a different project has the wrong search path and packages,
	-- so replace it rather than loading into it.
	if alive() and state.root ~= root then
		vim.fn.jobstop(state.chan)
		vim.api.nvim_buf_delete(state.buf, { force = true })
		state.buf, state.chan, state.root = nil, nil, nil
	end

	if alive() then
		if not window_showing(state.buf) then
			vim.cmd("botright vsplit")
			vim.api.nvim_win_set_buf(0, state.buf)
			vim.api.nvim_set_current_win(cur)
		end
		return true
	end

	-- `vnew`, not `vsplit`: a plain split shows the *same* buffer in both
	-- windows, and jobstart({term=true}) attaches the pty to the current
	-- buffer -- which would turn the Haskell buffer itself into the terminal.
	vim.cmd("botright vnew")
	local chan = vim.fn.jobstart(cmd, {
		term = true,
		cwd = root,
		on_exit = function()
			state.buf, state.chan, state.root = nil, nil, nil
		end,
	})
	if chan <= 0 then
		vim.cmd("close")
		vim.notify("ghci: failed to start `" .. cmd .. "`", vim.log.levels.ERROR)
		return false
	end
	state.chan, state.root = chan, root
	state.buf = vim.api.nvim_get_current_buf()
	vim.bo[state.buf].buflisted = false

	-- Entering the repl window should let you type immediately. Nvim drops into
	-- normal mode on window enter, which is right for a file and wrong for a
	-- prompt. Scoped to this buffer so other terminals keep the default.
	-- <C-\><C-n> still leaves terminal mode for normal/visual on the scrollback,
	-- and does not re-fire this because the window never changes.
	vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
		buffer = state.buf,
		callback = function()
			if vim.api.nvim_get_current_buf() == state.buf then
				vim.cmd("startinsert")
			end
		end,
	})

	vim.api.nvim_set_current_win(cur)
	return true
end

local function send(line)
	vim.fn.chansend(state.chan, line .. "\n")
	-- Follow the output if the pane is visible but not focused.
	local win = window_showing(state.buf)
	if win then
		vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(state.buf), 0 })
	end
end

-- Write the buffer (the repl reads the file from disk, not from nvim) and load it.
function M.load()
	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		vim.notify("ghci: buffer has no file name", vim.log.levels.WARN)
		return
	end
	vim.cmd("silent update")
	local root, cmd = repl_for(vim.fs.dirname(file))
	if ensure_repl(root, cmd) then
		send(':load "' .. file .. '"')
	end
end

-- Cheaper than :load once the file is already loaded, and keeps whatever module
-- is currently in scope rather than switching to this buffer's file.
function M.reload()
	if not alive() then
		return M.load()
	end
	vim.cmd("silent update")
	send(":reload")
end

function M.quit()
	if alive() then
		send(":quit")
	end
end

vim.api.nvim_create_user_command("Ghci", M.load, { desc = "Load current file into a repl on the right" })
vim.api.nvim_create_user_command("GhciReload", M.reload, { desc = "Reload the repl" })
vim.api.nvim_create_user_command("GhciQuit", M.quit, { desc = "Quit the repl" })

return M
