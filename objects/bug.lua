-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Actor = require("objects.actor")
local Bug = Actor:extend("bug")


function Bug:init(x, y)
    -- Core
    self:setDimensions(8, 5)
    self.acc    = {x=3, y=3}
    self.vel    = {x=0, y=0}
    self.max_vel= {x=10, y=150}
    self.damp   = {x=0, y=0}
    self.health = 50
    self.move_filter = function(other)
        if other.type == "tile" and other.solid then return "cross" end
    end
    -- Init
    Actor.init(self, x, y+3, {collide=true, can_die=true, deadly=true})
    -- Additional
    -- Random movement direction when spawning
    local dir = love.math.random(1, 2)
    if dir == 1 then self.dir.x  = -1
    else self.dir.x = 1 end
    -- Add sprite
    self:newAnimation(self.name, Game.assets.anim.bug, '1-6', 1, .15)
    self:setSprite(self.name)
    self.sprite:gotoFrame(math.random(1, #self.sprite.frames))
    return self
end


function Bug:onCollision(other)
    if other.name ~= "bug" then
        Actor.onCollision(self, other)
    end
end


function Bug:onDamage(amount, other)
    for i=1, math.random(5, 10) do
        local x, y = self:getCenter()
        Game.level:spawn("particle", x, y, Game.assets.data.particles.blood)
    end
    local pitch = math.random(75, 125)/100
    Game:playSound("splat"):setPitch(pitch)
end


function Bug:logic(dt)
    if self.dir.x < 0 then self.sprite.flippedH = true
    else self.sprite.flippedH = false end
    -- AI movement on platform
    local x = self.x + self.vel.x * dt
    local y = self.y + self.vel.y * dt
    if self.in_air then return end
    if self.dir.x > 0 then
        local right = Game.level.collision_world:queryPoint(x+(self.width+1), y+(self.height/2), self.move_filter)
        local downRight = Game.level.collision_world:queryPoint(x+(self.width+1), y+(self.height+1), self.move_filter)
        if #downRight==0 or #right > 0 then self.dir.x = -1 end
    elseif self.dir.x < 0 then
        local left = Game.level.collision_world:queryPoint(x-1, y+(self.height/2), self.move_filter)
        local downLeft = Game.level.collision_world:queryPoint(x-1, y+(self.height+1), self.move_filter)
        if #downLeft==0 or #left > 0 then self.dir.x = 1 end
    end
end

return Bug
