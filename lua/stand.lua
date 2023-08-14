local M = {}

function M.setup(options)
	options = options or {}
	options.minute_interval = (options.minute_interval or 60) * 60 * 1000

	local timer = vim.loop.new_timer()
	local enabled = true

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
	end, { desc = "Display time remaining until next stand." })

	vim.api.nvim_create_user_command("StandNow", function()
		if has_notify then
			require("notify").dismiss()
		end

		timer:stop()
		timer:again()
	end, { "Stand, dismissing any notifications and restarting the timer." })

	vim.api.nvim_create_user_command("StandEvery", function(opts)
		options.minute_interval = tonumber(opts.args) * 60 * 1000
		local remaining = timer:get_due_in()
		timer:stop()
		timer:start(remaining, options.minute_interval, vim.schedule_wrap(on_timer)) -- Start timer with new time
	end, { desc = "Set the stand interval in minutes for future timers.", nargs = 1 })

	vim.api.nvim_create_user_command("StandDisable", function()
		if not enabled then
			vim.print("Standing already disabled.")
			return
		end
		timer:stop()
		vim.print("Standing disabled.")
		enabled = false
		if has_notify then
			require("notify").dismiss()
		end
	end, { desc = "Disable the stand timer." })

	vim.api.nvim_create_user_command("StandEnable", function()
		if enabled then
			vim.print("Standing already enabled.")
			return
		end
		timer:again()
		vim.print("Standing enabled.")
		enabled = true
	end, { desc = "Enable the stand timer." })
end

return M
