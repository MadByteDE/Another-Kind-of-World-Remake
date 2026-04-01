-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Actor = require("objects.actor")
local Player = Actor:extend("player")


function Player:init(x, y)
    -- Core
    self:setDimensions(6, 7)
    Actor.init(self, x, y, {collide=true, can_die=true})
    -- Properties
    self.acc    = {x=35, y=110}
    self.vel    = {x=0, y=0}
    self.max_vel= {x=70, y=150}
    self.damp   = {x=30, y=0}
    self.max_bombs = 3
    if Game.debug then self.max_bombs = 99 end
    self.health = 100
    -- Add sprite(s)
    self:newAnimation("idle", Game.assets.anim.player_idle, '1-2', 1, .3)
    self:newAnimation("run", Game.assets.anim.player_run, '1-4', 1, .15)
    self:setSprite("idle")
end


function Player:onDamage(amount, other)
    for i=1, math.random(5, 10) do
        local x, y = self:getCenter()
        Game.level:spawn("particle", x, y, Game.assets.data.particles.blood)
    end
    local pitch = math.random(75, 125)/100
    Game:playSound("splat"):setPitch(pitch)
end


function Player:onDead(other)
    self:destroy()
    Game.scene:fail()
end


function Player:onCollision(other)
    Actor.onCollision(self, other)
    if other.name == "exit" then
        self:destroy()
        Game.scene:success()
    end
end


function Player:logic(dt)
    local keyDown = love.keyboard.isDown
    -- always reset direction
    self.dir = {x=0, y=0}
    -- Set default sprite
    self:setSprite("idle")
    -- Look towards the cursor
    local mx, my = Game:getMousePosition()
    self.sprite.flippedH = (mx < self.x+self.width/2)
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
end


function Player:keypressed(key)
    if key == "w" or key == "up" or key == "space" then
        self:jump()
    end
end


function Player:keyreleased(key)
    if key == "w" or key == "up" or key == "space" then
        self.vel.y = self.vel.y/1.6
    end
end


function Player:mousereleased(x, y, button)
    if button == 1 and #Game.level:getObject("bomb") < self.max_bombs then
        self:throw("bomb")
    end
end

return Player