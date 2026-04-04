-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Tween = require("lib.tween")
local Actor = require("objects.actor")
local Particle = Actor:extend("particle")

local fadeout_time = .125

function Particle:init(x, y, data)
    -- Core
    local sprite = data.images[math.random(1, #data.images)]
    self:setDimensions(sprite:getDimensions())
    Actor.init(self, x-self.width/2-1, y-self.height/2-1, data)
    -- Properties
    self.lifetime = (data.lifetime or .75) + (math.random(-10, 10)/50)
    self.vel.x = math.random(data.range.x[1], data.range.x[2])
    self.vel.y = math.random(data.range.y[1], data.range.y[2])
    self.rgba[4] = .65
    self.alpha_tween = Tween.new(fadeout_time, self.rgba, {[4]=0})
    -- Add sprite(s)
    self:newSprite(self.name, sprite)
    self:setSprite(self.name)
end


function Particle:onCollision(other)
    if other.name == "lava" then self:onDead() end
end


function Particle:logic(dt)
    -- Fade out
    if self.lifetime <= fadeout_time then
        self.alpha_tween:update(dt)
    end
end

return Particle
