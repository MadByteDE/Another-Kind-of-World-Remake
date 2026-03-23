-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Actor = require("objects.actor")
local Player  = Class()
Player:include(Actor)


function Player:init(level, x, y)
    -- Init
    Actor.init(self, level, x, y, {collide=true, solid=true, can_die=true})
    self.type   = "player"
    self.dim    = {w=6, h=7}
    self.trans  = {r=0, sx=1, sy=1, ox=1, oy=1}
    self.acc    = {x=35, y=110}
    self.vel    = {x=0, y=0, lx=70, ly=150}
    self.damp   = {x=30, y=0}
    self.gravity = 33
    self.max_bombs = 3
    if Game.debug then self.max_bombs = 99 end
    -- Additional
    self:newAnimation("idle", Game.assets.anim.player_idle, '1-2', 1, .3)
    self:newAnimation("run", Game.assets.anim.player_run, '1-4', 1, .15)
    self:setSprite("idle")
end


function Player:onDead(v)
    Actor.onDead(self)
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
        self.level:spawn("particle", self.pos.x, self.pos.y, data)
    end
    local pitch = math.random(75, 125)/100
    Game:playSound("splat"):setPitch(pitch)
    Game.scene:fail()
end


function Player:onCollision(other)
    Actor.onCollision(self, other)
    if other.type == "exit" then
        self:destroy()
        Game.scene:success()
    end
end


function Player:throw(name, data)
    local name = name or "bomb"
    if #self.level:getObject(name) < self.max_bombs then
        local mouse = Game.gui:getMouse()
        local dist_x = mouse.pos.x-self.pos.x+self.dim.w/2
        local dist_y = mouse.pos.y-self.pos.y+self.dim.h/2
        local angle = math.sqrt(dist_x*dist_x + dist_y*dist_y)
        local data  = data or {}
        data.parent = self
        data.dx     = (mouse.pos.x-self.pos.x)/angle
        data.dy     = (mouse.pos.y-self.pos.y)/angle
        self.level:spawn(name, self.pos.x+self.dim.w/2, self.pos.y+2, data)
        Game:playSound("toss")
        -- Pushback
        self.vel.x = self.vel.x + (random_range(70, 10) * -data.dx)
        self.vel.y = self.vel.y + (random_range(50, 15) * -data.dy)
    end
end


function Player:logic(dt)
    local mouse = Game.gui:getMouse()
    local keyDown = love.keyboard.isDown
    -- always reset direction
    self.dir.x = 0
    self.dir.y = 0
    -- Set default sprite
    self:setSprite("idle")
    -- Look towards the cursor
    if mouse.pos.x > self.pos.x+self.dim.w/2 then
    self.sprite.flippedH = false
    else self.sprite.flippedH = true end
    -- Prevent jumping while in air
    if self.vel.y > 50 then self.in_air = true end
    -- Key movement
    if keyDown("a") or keyDown("left")  then
        self:setSprite("run")
        self.sprite.flippedH = true
        self.dir.x = -1
    end
    if keyDown("d") or keyDown("right") then
        self:setSprite("run")
        self.sprite.flippedH = false
        self.dir.x = 1
    end
    self:accelerate(dt) -- accelerate instead of moving at a constant speed
end


function Player:keypressed(key)
    if key == "w" or key == "up" or key == "space" then
        if not self.in_air then
            local pitch = math.random(75, 125)/100
            Game:playSound("jump", .7):setPitch(pitch)
        end
        self:jump()
    end
end


function Player:keyreleased(key)
    if key == "w" or key == "up" or key == "space" then
        self.vel.y = self.vel.y/1.6
    end
end


function Player:mousereleased(x, y, button)
    if button == 1 then self:throw() end
end

return Player