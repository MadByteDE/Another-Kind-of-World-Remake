-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Actor = require("objects.actor")
local Particle = Class()
Particle:include(Actor)


function Particle:init(level, x, y, data)
    -- Init
    Actor.init(self, level, x, y, data)
    self.pos.x  = self.pos.x + self.dim.w/2
    self.pos.y  = self.pos.y + self.dim.h/2
    self.trans  = data.trans or {r=math.random(-24, 24), sx=1, sy=1, ox=4, oy=4}
    self.lifetime = data.lifetime or .75
    self.gravity = data.gravity or 25
    self.rgba[4] = .8
    self.wrap   = false
    -- Additional
    self:newSprite(self.type, data.images[math.random(1, #data.images)])
    self:setSprite(self.type)
end


function Particle:logic(dt)
    self.trans.r = self.trans.r + 2 * dt
    if self._lifetime <= self.lifetime/4 then self.rgba[4] = self.rgba[4] - (5 * dt) end
end

return Particle
