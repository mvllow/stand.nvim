local M = {}

function M.setup(options)
	options = options or {}
	options.minute_interval = (options.minute_interval or 60) * 60 * 1000

	local timer = vim.loop.new_timer()

	local has_notify, notify = pcall(require, "notify")
	if has_notify then
		vim.notify = notify
	end

	local function on_timer()
		vim.notify(" ⏰ Time to stand ", vim.log.levels.WARN, {
			title = "stand.nvim",
			render = "minimal",
			timeout = false,
			on_open = function()
				timer:stop()
			end,
			on_close = function()
				timer:again()
			end,
		})
	end

	timer:start(options.minute_interval, options.minute_interval, vim.schedule_wrap(on_timer))

	vim.api.nvim_create_user_command("StandWhen", function()
		local minutes_remaining = math.ceil(timer:get_due_in() / 60 / 1000)
		vim.print(
			string.format(
				"Stand in " .. minutes_remaining .. " %s, or sooner",
				minutes_remaining == 1 and "minute" or "minutes"
			)
		)
	end, {})

	vim.api.nvim_create_user_command("StandNow", function()
		if has_notify then
			require("notify").dismiss()
		end

		timer:stop()
		timer:again()
	end, {})
end

return M
