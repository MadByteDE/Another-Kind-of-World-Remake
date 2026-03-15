-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Actor = require("objects.actor")
local Particle = Class()
Particle:include(Actor)


function Particle:init(level, x, y, sprites)
    -- Init
    Actor.init(self, level, x, y)
    self.pos.x  = self.pos.x + self.dim.w/2
    self.pos.y  = self.pos.y + self.dim.h/2
    self.trans  = {r=math.random(-24, 24), sx=1, sy=1, ox=4, oy=4}
    self.vel    = {x=math.random(-40, 40), y=-love.math.random(40, 120), lx=100, ly=100}
    self.gravity = 25
    self.lifetime = .75
    self.wrap = false
    -- Additional
    self:newSprite(self.type, sprites[math.random(1, #sprites)])
    self:setSprite(self.type)
end


function Particle:logic(dt)
    self.trans.r = self.trans.r + 2 * dt
    if self.lifetime <= .25 then self.rgba[4] = self.rgba[4] - (5 * dt) end
end

return Particle
