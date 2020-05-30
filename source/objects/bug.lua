
local Bug = Class()
Bug:include(Actor)


function Bug:init(world, x, y)
  -- Core
  self.type     = "bug"
  self.dim      = {w=8, h=6}
  self.trans    = {r=0, sx=1, sy=1, ox=0, oy=2}
  self.acc      = {x=3,y=0}
  self.vel      = {x=0,y=0,lx=10,ly=0}
  self.damp     = {x=0,y=0}
  self.filter   = function(other)
    if other.solid then
      return "slide"
    else return end
  end
  -- Init
  Actor.init(self, world, x, y, {collide=true, canDie=true, deadly=true})
  -- Additional
  -- Random movement direction when spawning
  local dir = love.math.random(1, 2)
  if dir == 1 then self.dir.x  = -1
  else self.dir.x = 1 end
  -- Add sprite
  self:newSprite(self.type, Assets.spritesheet, Assets.getAnimation(self.type))
  self:setSprite(self.type)
  self.sprite:gotoFrame(math.random(1, #self.sprite.frames))
end


function Bug:logic(dt)
  if self.dir.x < 0 then self.sprite.flippedH = true
  else self.sprite.flippedH = false end
  self:accelerate(dt)
  -- AI movement on platform
  local x = self.pos.x + self.vel.x * dt
  local y = self.pos.y + self.vel.y * dt
  if self.dir.x > 0 then
    local right = self.collisionWorld:queryPoint(x+self.dim.w+1, y+(self.dim.h/2), self.filter)
    local downRight  = self.collisionWorld:queryRect(x+self.dim.w, y+self.dim.h, 2, 2, self.filter)
    if #downRight==0 or #right > 0 then self.dir.x = -1 end
  elseif self.dir.x < 0 then
    local left  = self.collisionWorld:queryPoint(x-1, y+(self.dim.h/2), self.filter)
    local downLeft  = self.collisionWorld:queryRect(x-3, y+self.dim.h, 2, 2, self.filter)
    if #downLeft==0 or #left > 0 then self.dir.x = 1 end
  end
end

return Bug
