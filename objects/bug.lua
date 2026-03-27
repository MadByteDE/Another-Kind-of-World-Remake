-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Actor = require("objects.actor")
local Bug = Class()
Bug:include(Actor)


function Bug:init(x, y)
    -- Core
    self.type   = "bug"
    self:setDimensions(8, 6)
    self.offset = {x=0, y=2}
    self.acc    = {x=3, y=0}
    self.vel    = {x=0, y=0, lx=10, ly=0}
    self.damp   = {x=0, y=0}
    self.health = 50
    self.filter = function(other)
        if other.solid then return "slide"
        else return end
    end
    -- Init
    Actor.init(self, x, y, {collide=true, can_die=true, deadly=true})
    -- Additional
    -- Random movement direction when spawning
    local dir = love.math.random(1, 2)
    if dir == 1 then self.dir.x  = -1
    else self.dir.x = 1 end
    -- Add sprite
    self:newAnimation(self.type, Game.assets.anim.bug, '1-6', 1, .15)
    self:setSprite(self.type)
    self.sprite:gotoFrame(math.random(1, #self.sprite.frames))
    return self
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
    self:accelerate(dt)
    -- AI movement on platform
    local x = self.x + self.vel.x * dt
    local y = self.y + self.vel.y * dt
    if self.dir.x > 0 then
        local right = Game.level.collision_world:queryPoint(x+self.width+1, y+(self.height/2), self.filter)
        local downRight  = Game.level.collision_world:queryRect(x+self.width, y+self.height, 2, 2, self.filter)
        if #downRight==0 or #right > 0 then self.dir.x = -1 end
    elseif self.dir.x < 0 then
        local left  = Game.level.collision_world:queryPoint(x-1, y+(self.height/2), self.filter)
        local downLeft  = Game.level.collision_world:queryRect(x-3, y+self.height, 2, 2, self.filter)
        if #downLeft==0 or #left > 0 then self.dir.x = 1 end
    end
end


-- function Bug:render()
--     love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
-- end

return Bug
