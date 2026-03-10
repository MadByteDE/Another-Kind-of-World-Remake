
-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

NAME       = "Another Kind of World (Remake)"
VERSION    = "1.3"

-- Optimize seed randomization (OS time incl. milliseconds)
local socket = require("socket")
math.randomseed(socket.gettime() * 10000)

-- Display terminal messages immediately
io.stdout:setvbuf("no")

-- Start debugger
if arg[2] == "debug" then require("lldebugger").start() end

love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setLineWidth(.1)
love.mouse.setVisible(false)
if arg[2] ~= "debug" then love.mouse.setGrabbed(true) end
love.keyboard.setKeyRepeat(true)
_NULL_ = function() end

-- Libs
require("src.lib.utils")
Class  = require("src.lib.class")
Bump   = require("src.lib.bump")
Anim8  = require("src.lib.anim8")
Conta  = require("src.lib.conta")
-- Core
Game = require("src.game")

local callbacks = {"load", "update", "draw"}

-- Fetch event callbacks
for k in pairs(love.handlers) do
	callbacks[#callbacks+1] = k
end


-- Initialize main game loop
for _,f in ipairs(callbacks) do
    Game[f] = Game[f] or _NULL_
    love[f] = function(...)
        Game[f](Game, ...)
    end
end


function love.errorhandler(msg)
    local error_msg = debug.traceback(tostring(msg), 1 + (2)):gsub("\n[^\n]+$", "")

    -- Print error message to screen and log file
    if Game.log then
        Game.log:error(error_msg)
        Game.log:saveToFile()
    else print(error_msg) end

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


function love.quit()
    Game.log:saveToFile()
end