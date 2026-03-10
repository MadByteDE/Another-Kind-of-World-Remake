-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Actor = require("src.objects.actor")
local Particle = Class()
Particle:include(Actor)


function Particle:init(level, x, y, quads)
    -- Init
    Actor.init(self, level, x, y)
    self.pos.x    = self.pos.x - love.math.random(-12, 12)
    self.pos.y    = self.pos.y - love.math.random(-12, 12)
    self.trans    = {r=love.math.random(-24, 24), sx=1, sy=1, ox=4, oy=4}
    self.vel      = {x=love.math.random(-10, 10), y=-love.math.random(30, 60), lx=100, ly=100}
    self.gravity  = 25
    self.lifetime = .75
    self.noWrap   = true
    -- Additional
    self:newSprite(self.type, Game.assets.spritesheet, quads[math.random(1, #quads)])
    self:setSprite(self.type)
end


function Particle:logic(dt)
    self.trans.r = self.trans.r + 2 * dt
    if self.lifetime <= .25 then self.rgba[4] = self.rgba[4] - (5 * dt) end
end

return Particle
