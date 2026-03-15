-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

_NULL = function() end

-- Display terminal messages immediately
io.stdout:setvbuf("no")

-- Start debugger
if arg[2] == "debug" then require("lldebugger").start() end

-- Core modules
Log     = require("lib.log").create("latest")
Game    = require("game")

-- Fetch event callbacks
local callbacks = {"load", "update", "draw"}
for k in pairs(love.handlers) do callbacks[#callbacks+1] = k end

-- Initialize game
for _,f in ipairs(callbacks) do
    Game[f] = Game[f] or _NULL
    love[f] = function(...) Game[f](Game, ...) end
end

function love.errorhandler(msg)
    -- Print error message to screen and log file
    local error_msg = debug.traceback(tostring(msg), 1 + (2)):gsub("\n[^\n]+$", "")
    local f = function()
        if Log then
            Log:error(error_msg)
            Log:saveToFile()
        else print(error_msg) end
    end
    if not pcall(f) then print(error_msg) end
    -- No need to continue if certain modules are not enabled
    if not love.window or not love.graphics or not love.event then
        return
    end
    -- Reset input states
    if love.mouse then
        love.mouse.setVisible(true)
        love.mouse.setGrabbed(false)
        love.mouse.setRelativeMode(false)
        if love.mouse.isCursorSupported() then
            love.mouse.setCursor()
        end
    end
    if love.joystick then
        for i, v in ipairs(love.joystick.getJoysticks()) do
            v:setVibration()
        end
    end
    -- Reset audio state
    if love.audio then love.audio.stop() end
end