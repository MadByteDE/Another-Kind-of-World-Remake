
local Screen  = require("source.screen")
local Assets  = require("source.assets")
local Class   = require("source.lib.class")
local Actor   = require("source.actor")
local Bug     = Class()
Bug:include(Actor)


function Bug:init(world, x, y)
  Actor.init(self, world, x+1, y+2, {collides=true})
  self.type     = "bug"
  self.dim      = {w=8, h=6}
  self.trans    = {r=0, sx=1, sy=1, ox=0, oy=2}
  self.acc      = {x=3,y=0}
  self.vel      = {x=0,y=0,lx=10,ly=0}
  self.damp     = {x=0,y=0}
  self.isAI     = true
  self.canDie   = true
  self.filter   = function(other)
    if other.isSolid then
      return "slide"
    else return end
  end
  -- Random dir when spawning
  local dir = love.math.random(1, 2)
  if dir == 1 then self.dir.x  = -1
  else self.dir.x = 1 end
  -- Sprite(s)
  self:newAnimation("idle", '1-6', 2, .15)
  self:setAnimation("idle")
end


function Bug:logic(dt)
  if self.dir.x < 0 then self.sprite.flippedH = true
  else self.sprite.flippedH = false end
  self:accelerate(dt)
end


function Bug:render()
  --self:drawRectangle("line")
end

return Bug
