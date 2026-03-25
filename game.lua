-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

-- Optimize seed randomization
local socket = require("socket")
math.randomseed(socket.gettime() * 10000)

-- Configure graphics
love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setLineWidth(.1)

-- Dependencies
require("utils")
Class       = require("lib.class")
local Gui   = require("gui")
local Level = require("level")

local Game = {
    title   = "Another Kind of World",
    version = "1.3",
    debug   = (arg[2] == "debug") or false,
    width   = 256, height = 160,
    assets  = require("lib.cargo").init('assets'),
    scene   = {
        init=_NULL, leave=_NULL,
        update=_NULL, draw=_NULL,
        keypressed=_NULL, keyreleased=_NULL,
        mousepressed=_NULL, mousereleased=_NULL,
        textinput = _NULL,
    },
    _shake = {
        x=0, y=0,
        last_x=0, last_y=0,
        timer = 0, intensity = 1,
    },
    fade = {
        duration = 2, timer = 1,
        color = { .05, .05, .05 }, alpha = 1,
        triggered = false, onTransition = _NULL,
    },
}

local scenes = {
    Ingame  = require("scenes.ingame"),
    Editor  = require("scenes.editor"),
}

-- Configure inputs
if not Game.debug then love.mouse.setGrabbed(true) end
love.mouse.setVisible(false)
love.keyboard.setKeyRepeat(true)


function Game:load()
    Log:message("Logs will be saved in: %s", join( love.filesystem.getSaveDirectory(), "logs" ))
    -- Level
    Game.level = Level()
    -- Screen
    self:setMode(self.width*4, self.height*4, {usedpiscale=false})
    -- GUI
    self.gui = Gui()
    self.quit_button = self.gui:add("button", self.width-13, 3, {
        image   = self.assets.gui.button.back,
        action  = function(e, button)
            if button == 1 then
                self:transition(function() love.event.quit() end, 3)
            end
    end})
    -- Start-up
    love.graphics.setFont(self.assets.font.tinypixels(8))
    self:playSound("music", .275, true)
    Game:switchScene("Ingame", 0)
end


function Game:getWindowSize()
    return self.width * self.scale.x, self.height * self.scale.y
end


function Game:setMode(w, h, flags)
    local w = w or love.graphics.getWidth()
    local h = h or love.graphics.getHeight()
    self.scale = self.scale or {}
    self.scale.x = w/self.width
    self.scale.y = h/self.height
    self.flags = self.flags or {}
    for k,v in pairs(flags or {}) do self.flags[k] = v end
    local w, h = self:getWindowSize()
    love.window.setMode(w, h, self.flags)
end


function Game:print(text, x, y, color, ...)
    love.graphics.setColor(color or {1, 1, 1, 1})
    love.graphics.print(text, x, y, ...)
    love.graphics.setColor(1, 1, 1, 1)
end


function Game:printf(text, x, y, width, align, color, ...)
    love.graphics.setColor(color or {1, 1, 1, 1})
    love.graphics.printf(text, x, y, width, align, ...)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(previousFont)
end


function Game:playSound(name, vol, loop)
    local snd = self.assets.sound[string.lower(name)]:clone()
    local vol = vol or 1
    if vol then snd:setVolume(vol) end
    if snd:isPlaying() then snd:stop() end
    snd:play()
    if loop ~= nil then snd:setLooping(loop) end
    return snd
end


function Game:transition(onTransition, duration, color)
    self.fade.duration = duration or 2
    self.fade.timer = self.fade.duration
    self.fade.color = color or {.05, .05, .05}
    self.fade.triggered = false
    self.fade.onTransition = onTransition or function()end
end


function Game:shake(time, intensity)
    self._shake.timer = time or .75
    self._shake.intensity = intensity or 2
end


function Game:switchScene(name, ...)
    if not scenes[name] then
        Log:error("Scene '%s' does not exist", name)
        return
    end
    if self.scene then self.scene:leave() end
    self.scene = scenes[name]
    self.scene:init(...)
end


function Game:update(dt)
    -- Screen shake
    if self._shake.timer > 0 then
        self._shake.timer = self._shake.timer - dt
        local amount = self._shake.timer*self._shake.intensity
        self._shake.x = math.random(-amount, amount)
        self._shake.y = math.random(-amount, amount)
    else
        self._shake.timer = 0
    end
    -- Screen transition
    if self.fade.timer > 0 then
        self.fade.timer = self.fade.timer - dt
    else self.fade.timer = 0 end
    local step = self.fade.duration/2
    if self.fade.timer <= step and not self.fade.triggered then
        self.fade.triggered = true
        self.fade.onTransition()
    end
    local elapsed = self.fade.duration-self.fade.timer
    self.fade.alpha = elapsed/step * self.fade.timer/step
    -- Update current scene
    self.scene:update(dt)
    self.gui:update(dt)
end


function Game:draw()
    love.graphics.push()
    love.graphics.translate(self._shake.x, self._shake.y)
    love.graphics.scale(self.scale.x, self.scale.y)
    self.scene:draw()
    self.gui:draw()
    local r, g, b = self.fade.color[1], self.fade.color[2], self.fade.color[3]
    love.graphics.setColor(r, g, b, self.fade.alpha)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
    love.graphics.setColor(1, 1, 1, .45)
    love.graphics.draw(self.assets.image.dirtcover)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
end


function Game:keypressed(key, ...)
    self.scene:keypressed(key, ...)
    self.gui:keypressed(key, ...)
end


function Game:keyreleased(...)
    self.scene:keyreleased(...)
    self.gui:keyreleased(...)
end


function Game:mousepressed(...)
    self.scene:mousepressed(...)
    self.gui:mousepressed(...)
end


function Game:mousereleased(...)
    self.scene:mousereleased(...)
    self.gui:mousereleased(...)
end


function Game:wheelmoved(...)
    self.scene:wheelmoved(...)
    self.gui:wheelmoved(...)
end

function Game:textinput(...)
    self.scene:textinput(...)
    self.gui:textinput(...)
end


function Game:quit()
    Log:saveToFile()
end

return Game