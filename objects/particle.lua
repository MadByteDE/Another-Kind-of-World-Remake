-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Actor = require("objects.actor")
local Particle = Class()
Particle:include(Actor)


function Particle:init(x, y, data)
    -- Init
    Actor.init(self, x, y, data)
    local sprite = data.images[math.random(1, #data.images)]
    self.type = "particle"
    self.lifetime = data.lifetime or .75
    self.gravity = data.gravity or 25
    self.wrap = data.wrap or false
    self:setDimensions(sprite:getDimensions())
    self:setPosition(x-self.width/2, y-self.height/2)
    self.vel = {
        x=math.random(data.range.x[1], data.range.x[2]),
        y=math.random(data.range.y[1], data.range.y[2]),
        lx=150, ly=150,
    }
    self.rgba[4] = .75
    -- Additional
    self:newSprite(self.type, sprite)
    self:setSprite(self.type)
end


function Particle:logic(dt)
    if self._lifetime <= self.lifetime/4 then self.rgba[4] = self.rgba[4] - (5 * dt) end
    self:accelerate(dt)
end

return Particle
