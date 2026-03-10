-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.


local Screen = {}

function Screen:init(data)
    local data = data or {}
    self._shake = { x=0, y=0, last_x=0, last_y=0, timer = 0, intensity = 1 }
    self.fade = {
        duration = 0,
        timer = 0,
        color = { 1, 1, 1 },
        alpha = 0,
        triggered = false,
        onTransition = function() end,
    }
    self.flags = {usedpiscale = false}
    self:set(data)
end


function Screen:setDimensions(width, height)
    self.width = width or self.width or love.graphics.getWidth()
    self.height = height or self.height or love.graphics.getHeight()
end


function Screen:getDimensions()
    return self.width, self.height
end


function Screen:set(data)
    local data = data or {}
    self.scale = data.scale or self.scale or 1
    self:setDimensions(data.width, data.height)
    for k,v in pairs(data.flags or {}) do self.flags[k] = v end
    love.window.setMode(self.width * self.scale, self.height * self.scale, self.flags)
end


function Screen:update(dt)
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
    if self.fade.timer <= self.fade.duration/2 and not self.fade.triggered then
    self.fade.onTransition()
    self.fade.triggered = true
    end
    local elapsed = self.fade.duration-self.fade.timer
    local step = self.fade.duration/2
    self.fade.alpha = elapsed/step * self.fade.timer/step
end


function Screen:push()
    love.graphics.push()
    love.graphics.translate(self._shake.x, self._shake.y)
    love.graphics.scale(self.scale, self.scale)
end


function Screen:pop()
    local r, g, b = self.fade.color[1], self.fade.color[2], self.fade.color[3]
    love.graphics.setColor(r, g, b, self.fade.alpha)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
end


function Screen:transition(onTransition, duration, color)
    self.fade.duration = duration or 2
    self.fade.timer = self.fade.duration
    self.fade.color = color or {.05, .05, .05}
    self.fade.triggered = false
    self.fade.onTransition = onTransition or function()end
end


function Screen:shake(time, intensity)
    self._shake.timer = time or .75
    self._shake.intensity = intensity or 2
end

return Screen