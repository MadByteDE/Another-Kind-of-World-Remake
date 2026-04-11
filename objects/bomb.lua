-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Profiler = require("lib.profiler")
local Actor = require("objects.actor")
local Bomb = Actor:extend("bomb")


function Bomb:init(x, y, data)
    -- Core
    self:setDimensions(5, 5)
    self.offset = {x=-1, y=0}
    local x = x - self.width/2 - self.offset.x/2
    local y = y - self.height/2 - self.offset.y/2
    Actor.init(self, x, y, {collide=true})
    -- Properties
    self.damp   = {x=1.5, y=1}
    self.speed  = {x=150, y=150}
    local vel_x = (self.speed.x + math.abs(data.parent.vel.x)) * (data.dx or 0)
    local vel_y = (self.speed.y + math.abs(math.min(data.parent.vel.y, 0))) * (data.dy or 0)
    self.vel = {x=vel_x or 0,y=vel_y or 0}
    self.max_vel = {x=140, y=180}
    self.lifetime = math.random(3, 4)
    self.bounciness = .8
    -- Add sprite(s)
    self:setSprite(self.name, {image=Game.assets.anim.bomb, frames='1-4', row=1, duration=.1})
end


function Bomb:onCollision(other)
    if other.name == "lava" then self:onDead() end
    if other:instanceOf(Actor) then return end
    -- Reduce velocity with every collision
    self.vel.x = self.vel.x * .98
    self.vel.y = self.vel.y * .98
end


function Bomb:onDead()
    -- Effects
    local pitch = math.random(75, 125)/100
    Game:playSound("boom"):setPitch(pitch)
    Game:shake()
    -- Explosion particles
    if Game.debug then Profiler:zone("Bomb_Particles") end
    for i=1, math.random(20, 30) do
        local x, y = self.x + self.width/2, self.y + self.height/2
        Game.level:spawn("particle", x, y, Game.assets.data.particles.explosion)
    end
    if Game.debug then
        Profiler:zone_pop()
        Profiler:zone("Bomb_Col_Resolve")
    end
    -- Apply explosion damage
    local radius = 24
    local x, y = self:getCenter(-radius/2, -radius/2)
    local cols = Game.level.collision_world:queryRect(x, y, radius, radius)
    for k, other in ipairs(cols) do
        if other:instanceOf(Actor) then
            local x_speed = math.random(30, 100)
            local y_speed = math.random(70, 150)
            if self.x >= other.x then other.vel.x = -x_speed
            else other.vel.x = x_speed end
            if self.y >= other.y then other.vel.y = -y_speed
            else other.vel.y = y_speed/2 end
        end
        if other.can_die then other:damage(50, self) end
    end
    if Game.debug then Profiler:zone_pop() end
    -- Remove bomb
    self:destroy()
end

-- function Bomb:render() self:drawRectangle("line") end

return Bomb
