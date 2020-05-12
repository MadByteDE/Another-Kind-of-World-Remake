
local Screen  = require("source.screen")
local Assets  = require("source.assets")
local Class   = require("source.lib.class")
local Actor   = require("source.actor")
local Bomb    = require("source.bomb")
local Player  = Class()
Player:include(Actor)


function Player:init(world, x, y)
  local t = {collides=true, isSolid=true}
  Actor.init(self, world, x+1, y+1, t)
  self.type     = "player"
  self.dim      = {w=6, h=7}
  self.trans    = {r=0, sx=1, sy=1, ox=1, oy=1}
  self.acc      = {x=40,y=125}
  self.vel      = {x=0,y=0,lx=80,ly=120}
  self.damp     = {x=30,y=0}
  self.gravity  = 30
  self.canDie   = true
  -- Sprite(s)
  self:newAnimation("idle", '1-6', 1, .1)
  self:setAnimation("idle")
end


function Player:onDead()
  Actor.onDead(self)
  Screen:transition(function() self.world:init() end, .75, {.1, .05, .05})
  Assets.audio.play("fail", .25)
end


function Player:onCollision(col)
  local other = col.other
  if other.type == "bug" then
    self:onDead()
  elseif other.type == "exit" and other.collides then
    self:destroy()
    Assets.audio.play("success", .25)
    Screen:transition(function()
      self.world:init(self.world.level+1)
    end, 1)
  end
end


function Player:logic(dt)
  local keyDown = love.keyboard.isDown
  -- always reset direction
  self.dir.x = 0
  self.dir.y = 0
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
  if key == "w" or key == "rctrl" then
    if not self.inAir then Assets.audio.play("jump") end
    self:jump()
  end
end


function Player:mousereleased(x, y, button)
  local objects = self.world.objects
  if button == 1 and #objects:get("bomb") < 3 then
    objects:add(Bomb(self.world, self, x/Screen.scale, y/Screen.scale))
  end
end


function Player:render()
  --self:drawRectangle("line")
end

return Player
