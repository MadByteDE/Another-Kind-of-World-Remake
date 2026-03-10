-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Actor = require("src.objects.actor")
local Bomb = Class()
Bomb:include(Actor)


function Bomb:init(level, x, y, data)
    -- init
    self.type     = "bomb"
    self.dim      = {w=5, h=5}
    self.trans    = {r=0, sx=1, sy=1, ox=1, oy=3}
    self.damp     = {x=1.5,y=1.5}
    self.gravity  = 33
    self.lifetime = 3.5
    self.bounciness = .8
    self.speed = {x=150, y=150}
    local x = x - self.dim.w/2 - self.trans.ox/2
    local y = y - self.dim.h/2 - self.trans.oy/2
    Actor.init(self, level, x, y, {collide=true})
    local vel_x = (self.speed.x + math.abs(data.parent.vel.x)) * (data.dx or 0)
    local vel_y = (self.speed.y + math.abs(math.min(data.parent.vel.y, 0))) * (data.dy or 0)
    self.vel = {x=vel_x or 0,y=vel_y or 0,lx=400,ly=400}
    -- Additional
    self:newSprite(self.type, Game.assets.spritesheet, Game.assets.getAnimation(self.type))
    self:setSprite(self.type)
end


function Bomb:filter(other)
    if other.type == "player" then return "cross"
    elseif not other.solid then return
    else return "bounce" end
end


function Bomb:onCollision(other)
    if other.name == "lava" then self:destroy() end
end


function Bomb:onDead()
    Game.assets.playSound("boom")
    Game.screen:shake()
    local quads = {
        Game.assets.getQuad("sprite", {1, 3}),
        Game.assets.getQuad("sprite", {2, 3}),
        Game.assets.getQuad("sprite", {3, 3}),
    }
    for i=1, math.random(20,25) do
        self.level:spawn("particle", self.pos.x, self.pos.y, quads)
    end
    local radius = 24
    local x = self.pos.x+self.dim.w/2-radius/2
    local y = self.pos.y+self.dim.h/2-radius/2
    local cols = self.level.collisionWorld:queryRect(x, y, radius, radius)
    for i=1, #cols do
        local other = cols[i]
        if other.canDie then
            Game.assets.playSound("splat")
            other:onDead(self)
        end
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
