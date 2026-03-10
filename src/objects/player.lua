-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Actor = require("src.objects.actor")
local Player  = Class()
Player:include(Actor)


function Player:init(level, x, y)
    -- Init
    Actor.init(self, level, x, y, {collide=true, solid=true, canDie=true})
    self.type     = "player"
    self.dim      = {w=6, h=7}
    self.trans    = {r=0, sx=1, sy=1, ox=1, oy=1}
    self.acc      = {x=35,y=110}
    self.vel      = {x=0,y=0,lx=70,ly=150}
    self.damp     = {x=30,y=0}
    self.gravity  = 33
    self.max_bombs= 5
    -- Additional
    self:newSprite(self.type, Game.assets.spritesheet, Game.assets.getAnimation(self.type))
    self:setSprite(self.type)
end


function Player:onDead(v)
    Actor.onDead(self)
    Game.current_scene:fail()
end


function Player:onCollision(other)
    Actor.onCollision(self, other)
    if other.type == "exit" then
        self:destroy()
        Game.current_scene:success()
    end
end


function Player:logic(dt)
    local mouse = Game.current_scene:getMouse()
    local keyDown = love.keyboard.isDown
    -- always reset direction
    self.dir.x = 0
    self.dir.y = 0
    -- Look towards the cursor
    if mouse.pos.x > self.pos.x+self.dim.w/2 then
    self.sprite.flippedH = false
    else self.sprite.flippedH = true end
    -- Prevent jumping while in air
    if self.vel.y > 50 then self.inAir = true end
    -- Key movement
    if keyDown("a") or keyDown("left")  then
        self.sprite.flippedH = true
        self.dir.x = -1
    end
    if keyDown("d") or keyDown("right") then
        self.sprite.flippedH = false
        self.dir.x = 1
    end
    self:accelerate(dt) -- accelerate instead of moving at a constant speed
end


function Player:keypressed(key)
    if key == "w" or key == "up" or key == "space" then
        if not self.inAir then Game.assets.playSound("jump", .7) end
        self:jump()
    end
end


function Player:keyreleased(key)
    if key == "w" or key == "up" or key == "space" then
        self.vel.y = self.vel.y/1.6
    end
end


function Player:mousereleased()
    local mouse = Game.current_scene:getMouse()
    if mouse.button == 1 and #self.level:getObject("bomb") < self.max_bombs then
        local dist_x = mouse.pos.x-self.pos.x+self.dim.w/2
        local dist_y = mouse.pos.y-self.pos.y+self.dim.h/2
        local angle = math.sqrt(dist_x*dist_x + dist_y*dist_y)
        local dir_x = (mouse.pos.x-self.pos.x)/angle
        local dir_y = (mouse.pos.y-self.pos.y)/angle
        self.level:spawn("bomb", self.pos.x+self.dim.w/2, self.pos.y+2, {parent=self, dx=dir_x, dy=dir_y})
        Game.assets.playSound("toss")
        -- Pushback
        self.vel.x = self.vel.x + (75 * -dir_x)
        self.vel.y = self.vel.y + (50 * -dir_y)
    end
end

return Player