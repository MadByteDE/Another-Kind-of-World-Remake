local PATH = (...):gsub("%.init$", "")

local json = require(PATH .. ".lib.json")
local zone = require(PATH .. ".zone")

local profile = require("jit.profile")

local DEFAULT_MODE = "fi1"
local STACK_DEPTH  = 5

---@class Profiler
local Profiler = {
    channel_name = "profiler_events",

    running = false,
    trace_events = {},
    trace_start = 0,
    thread_name = "main",
    thread_id = 1,
    last_flushed_count = 0,

    thread_name_to_id = {
        main = 1
    },
    next_thread_id = 2,
    profiler_channel = nil
}

-- from batteries.
-- use it if available, otherwise create it
local string_split = string.split or function(self, delim, limit)
	delim = delim or ""
	limit = (limit ~= nil and limit) or math.huge

    assert(type(self) == "string", "string.split - self must be a string")
    assert(type(delim) == "string", "string.split - delim must be a string")
    assert(type(limit) == "number", "string.split - limit must be a number")

	if limit then
		assert(limit >= 0, "max_split must be positive!")
	end

	--we try to create as little garbage as possible!
	--only one table to contain the result, plus the split strings.
	--so we do two passes, and  work with the bytes underlying the string
	--partly because string.find is not compiled on older luajit :)
	local res = {}
	local length = self:len()
	--
	local delim_length = delim:len()
	--empty delim? split to individual characters
	if delim_length == 0 then
		for i = 1, length do
			table.insert(res, self:sub(i, i))
		end
		return res
	end
	local delim_start = delim:byte(1)
	--pass 1
	--collect split sites
	local i = 1
	while i <= length do
		--scan for delimiter
		if self:byte(i) == delim_start then
			local has_whole_delim = true
			for j = 2, delim_length do
				if self:byte(i + j - 1) ~= delim:byte(j) then
					has_whole_delim = false
					--step forward as far as we got
					i = i + j
					break
				end
			end
			if has_whole_delim then
				if #res < limit then
					table.insert(res, i)
					--iterate forward the whole delimiter
					i = i + delim_length
				else
					break
				end
			end
		else
			--iterate forward
			i = i + 1
		end
	end
	--pass 2
	--collect substrings
	i = 1
	for si, j in ipairs(res) do
		res[si] = self:sub(i, j-1)
		i = j + delim_length
	end
	--add the final section
	table.insert(res, self:sub(i, -1))
	--return the collection
	return res
end

---Start the profiler.
---@param mode? string  jit.profile mode string (default: "fi2")
---@param thread_name? string  Optional name for this thread (default: "main")
function Profiler:start(mode, thread_name)
    if self.running then
        return
    end

    print("Starting profiler")

    self.trace_events = {}
    self.trace_start = love.timer.getTime()
    self.running = true
    self.thread_name = thread_name or "main"
    self.last_flushed_count = 0

    if self.thread_name == "main" then
        self.thread_id = 1
        self.thread_name_to_id = { main = 1 }
        self.next_thread_id = 2
    else
        self.thread_id = nil
    end

    -- Only start sampling profiler on main thread (jit.profile doesn't work in worker threads)
    -- https://github.com/LuaJIT/LuaJIT/blob/v2.1/src/lj_profile.c#L84
    if self.thread_name == "main" then
        print("Starting sampling profiler with mode: " .. (mode or DEFAULT_MODE))

        profile.start(mode or DEFAULT_MODE, function(thread, count, vmstate)
            local stack = profile.dumpstack(thread, "plZ;", STACK_DEPTH)
            local ev = {
                ph = "i",
                name = "Sample",
                cat = "Sample",
                ts = self:get_timestamp(),
                pid = 1,
                tid = self.thread_id,
                s = "t",
                args = {
                    stack = table.concat(string_split(stack, ";"), "\n"),
                }
            }

            table.insert(self.trace_events, ev)
        end)
    end

    table.insert(self.trace_events, {
        ph = "M",
        name = "process_name",
        pid = 1,
        tid = self.thread_id,
        args = {
            name = love.filesystem.getIdentity()
        }
    })

    table.insert(self.trace_events, {
        ph = "M",
        name = "thread_name",
        pid = 1,
        tid = self.thread_id,
        args = {
            name = self.thread_name
        }
    })
end

--- Stop the profiler.
function Profiler:stop()
    if not self.running then
        return
    end

    print("Stopping profiler")
    profile.stop()
    self.running = false
end

---Get a timestamp in microseconds relative to the profiler start time.
function Profiler:get_timestamp()
    return (love.timer.getTime() - self.trace_start) * 1000 * 1000
end

--- Flush events to channel (Worker Threads)
--- Sends accumulated events to main thread
--- Call periodically or before stopping
function Profiler:flush_to_channel()
    if not self.running then
        return
    end

    -- Get or create channel
    if not self.profiler_channel then
        self.profiler_channel = love.thread.getChannel(self.channel_name)
    end

    -- Only send new events since last flush
    local new_events = {}
    for i = self.last_flushed_count + 1, #self.trace_events do
        table.insert(new_events, self.trace_events[i])
    end

    -- Update flush counter
    self.last_flushed_count = #self.trace_events

    -- Send batch with thread name, base time, and NEW events only
    if #new_events > 0 then
        local message = {
            thread_name = self.thread_name,
            base_time = self.trace_start,
            events = new_events
        }

        self.profiler_channel:push(message)
    end
end

---Collect worker events - called only from main thread!
function Profiler:collect_worker_events()
    if not self.running then
        return
    end

    if not self.profiler_channel then
        self.profiler_channel = love.thread.getChannel(self.channel_name)
    end

    -- Drain all pending messages
    while true do
        local message = self.profiler_channel:pop()

        if not message then
            break
        end

        local thread_name = message.thread_name
        local worker_base_time = message.base_time
        local worker_events = message.events

        if not self.thread_name_to_id[thread_name] then
            self.thread_name_to_id[thread_name] = self.next_thread_id
            self.next_thread_id = self.next_thread_id + 1

            table.insert(self.trace_events, {
                ph = "M",
                name = "thread_name",
                pid = 1,
                tid = self.thread_name_to_id[thread_name],
                args = {
                    name = thread_name
                }
            })
        end

        local worker_tid = self.thread_name_to_id[thread_name]

        for _, event in ipairs(worker_events) do
            if event.ph ~= "M" then
                local time_offset_us = (worker_base_time - self.trace_start) * 1000 * 1000
                local adjusted_ts = time_offset_us + event.ts

                event.ts = adjusted_ts
                event.tid = worker_tid
                table.insert(self.trace_events, event)
            end
        end
    end
end

---Write collected events to a Chrome JSON trace file.
---Open the file at https://ui.perfetto.dev/
---@param path? string Filename (default: "trace.json")
function Profiler:save_trace(path)
    path = path or "trace.json"

    local payload = {
        traceEvents = self.trace_events
    }

    local data = json.encode(payload)

    local ok, err = love.filesystem.write(path, data)

    if not ok then
        error("Failed to save trace: " .. tostring(err))
    else
        print(("Trace saved to %s/%s"):format(love.filesystem.getSaveDirectory(), path))
    end
end

---Stop the profiler and write the trace file.
---@param min_pct? number
function Profiler:stop_and_report(min_pct)
    self:stop()
    self:save_trace()
end

--- Toggle: start if stopped, stop_and_report if running.
---@param min_pct? number
function Profiler:toggle(min_pct)
    if self.running then
        self:stop_and_report(min_pct)
    else
        self:start()
    end
end

--- Returns whether the profiler is currently running.
---@return boolean
function Profiler:is_running()
    return self.running
end

--- Push a named zone (emits a B event in the trace).
---@param name string
function Profiler:zone(name)
    if self.running then
        local ev = {
            ph = "B",
            name = name,
            cat = "zone",
            ts = self:get_timestamp(),
            pid = 1,
            tid = self.thread_id
        }

        table.insert(self.trace_events, ev)
    end

    zone(name)
end

--- Pop the current zone (emits an E event in the trace).
---@return string?  The name of the zone that was popped.
function Profiler:zone_pop()
    local ts = self.running and self:get_timestamp() or nil
    local zone_name = zone()

    if ts then
        local ev = {
            ph = "E",
            name = zone_name or "?",
            cat = "zone",
            ts = ts,
            pid = 1,
            tid = self.thread_id
        }

        table.insert(self.trace_events, ev)
    end

    return zone_name
end

--- Return the name of the currently active zone (or nil).
---@return string?
function Profiler:get_zone_name()
    return zone:get()
end

return Profiler