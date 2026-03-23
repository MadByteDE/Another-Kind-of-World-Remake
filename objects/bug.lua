-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Actor = require("objects.actor")
local Bug = Class()
Bug:include(Actor)


function Bug:init(x, y)
    -- Core
    self.type   = "bug"
    self.dim    = {w=8, h=6}
    self.trans  = {r=0, sx=1, sy=1, ox=0, oy=2}
    self.acc    = {x=3, y=0}
    self.vel    = {x=0, y=0, lx=10, ly=0}
    self.damp   = {x=0, y=0}
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


function Bug:onDead(other)
    for i=1, math.random(10, 15) do
        local data = {}
        data.images = { Game.assets.particle.blood }
        data.lifetime = .5
        data.gravity = 25
        data.vel = {x=math.random(-25, 25), y=-love.math.random(40, 80), lx=100, ly=200}
        data.filter = function(other)
            if not other.solid then return "cross"
            else return end
        end
        Game.level:spawn("particle", self.pos.x, self.pos.y, data)
    end
    local pitch = math.random(75, 125)/100
    Game:playSound("splat"):setPitch(pitch)
    self:destroy()
end


function Bug:logic(dt)
    if self.dir.x < 0 then self.sprite.flippedH = true
    else self.sprite.flippedH = false end
    self:accelerate(dt)
    -- AI movement on platform
    local x = self.pos.x + self.vel.x * dt
    local y = self.pos.y + self.vel.y * dt
    if self.dir.x > 0 then
        local right = Game.level.collision_world:queryPoint(x+self.dim.w+1, y+(self.dim.h/2), self.filter)
        local downRight  = Game.level.collision_world:queryRect(x+self.dim.w, y+self.dim.h, 2, 2, self.filter)
        if #downRight==0 or #right > 0 then self.dir.x = -1 end
    elseif self.dir.x < 0 then
        local left  = Game.level.collision_world:queryPoint(x-1, y+(self.dim.h/2), self.filter)
        local downLeft  = Game.level.collision_world:queryRect(x-3, y+self.dim.h, 2, 2, self.filter)
        if #downLeft==0 or #left > 0 then self.dir.x = 1 end
    end
end


-- function Bug:render()
--     love.graphics.rectangle("line", self.pos.x, self.pos.y, self.dim.w, self.dim.h)
-- end

return Bug
