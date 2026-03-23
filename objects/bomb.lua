-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Actor = require("objects.actor")
local Bomb = Class()
Bomb:include(Actor)


function Bomb:init(level, x, y, data)
    -- init
    self.type   = "bomb"
    self.dim    = {w=5, h=5}
    self.trans  = {r=0, sx=1, sy=1, ox=1, oy=3}
    self.damp   = {x=1.5, y=1.5}
    self.gravity = 33
    self.lifetime = math.random(3, 4)
    self.bounciness = .8
    self.speed = {x=150, y=150}
    local x = x - self.dim.w/2 - self.trans.ox/2
    local y = y - self.dim.h/2 - self.trans.oy/2
    Actor.init(self, level, x, y, {collide=true})
    local vel_x = (self.speed.x + math.abs(data.parent.vel.x)) * (data.dx or 0)
    local vel_y = (self.speed.y + math.abs(math.min(data.parent.vel.y, 0))) * (data.dy or 0)
    self.vel = {x=vel_x or 0,y=vel_y or 0,lx=400,ly=400}
    -- Additional
    self:newAnimation(self.type, Game.assets.anim.bomb, '1-4', 1, .1)
    self:setSprite(self.type)
end


function Bomb:filter(other)
    if other.type == "player" then return "cross"
    elseif not other.solid then return
    else return "bounce" end
end


function Bomb:onCollision(other)
    if other.name == "lava" then
        self:onDead()
    end
    if other.type == "player" then return end
    -- Reduce velocity with every collision
    self.vel.x = self.vel.x * .98
    self.vel.y = self.vel.y * .98
end


function Bomb:onDead()
    local pitch = math.random(75, 125)/100
    Game:playSound("boom"):setPitch(pitch)
    Game:shake()
    local sprites = {
        Game.assets.particle.smoke,
        Game.assets.particle.fire,
    }
    for i=1, math.random(25,35) do
        local data = {}
        data.images = {Game.assets.particle.smoke, Game.assets.particle.fire}
        data.vel = {x=math.random(-40, 40), y=-love.math.random(40, 120), lx=100, ly=100}
        data.gravity = 25
        data.lifetime = .75
        self.level:spawn("particle", self.pos.x, self.pos.y, data)
    end
    local radius = 24
    local x = self.pos.x+self.dim.w/2-radius/2
    local y = self.pos.y+self.dim.h/2-radius/2
    local cols = self.level.collision_world:queryRect(x, y, radius, radius)
    for i=1, #cols do
        local other = cols[i]
        if other.type == "bomb" then
            local x_speed = math.random(30, 100)
            local y_speed = math.random(40, 200)
            if self.pos.x >= other.pos.x then other.vel.x = -x_speed
            else other.vel.x = x_speed end
            if self.pos.y >= other.pos.y then other.vel.y = -y_speed
            else other.vel.y = y_speed/2 end
        end

        if other.can_die then other:onDead(self) end
    end
    self:destroy()
end


function Bomb:logic(dt)
    self:accelerate(dt)
end


-- function Bomb:render()
--     love.graphics.rectangle("line", self.pos.x, self.pos.y, self.dim.w, self.dim.h)
-- end

return Bomb
