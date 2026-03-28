-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Tween = require("lib.tween")
local Actor = require("objects.actor")
local Particle = Actor:extend()

local fadeout_time = .3

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
    }
    self.max_vel = {x=150, y=150}
    self.rgba[4] = .65
    self.alpha_tween = Tween.new(fadeout_time, self.rgba, {[4]=0})
    -- Additional
    self:newSprite(self.type, sprite)
    self:setSprite(self.type)
end


function Particle:onCollision(other)
    if other.name == "lava" then self:onDead() end
end


function Particle:logic(dt)
    -- Fade out
    if self.lifetime <= fadeout_time then
        self.alpha_tween:update(dt)
    end
    -- Apply velocities
    self:accelerate(dt)
end

return Particle
