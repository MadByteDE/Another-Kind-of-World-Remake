
local Bomb = Class()
Bomb:include(Actor)


function Bomb:init(level, dx, dy, parent)
  -- init
  self.type     = "bomb"
  self.parent   = parent
  self.dim      = {w=6, h=6}
  self.trans    = {r=0, sx=1, sy=1, ox=.5, oy=2}
  self.damp     = {x=3.15,y=2}
  self.gravity  = 33
  self.lifetime = 3.5
  self.bounciness = .6
  local bx = parent.pos.x+parent.dim.w/2-self.dim.w/2-.5
  local by = parent.pos.y+parent.dim.h/2-self.dim.h/2-2
  Actor.init(self, level, bx, by, {collide=true, canDie=true})
  local dx = dx-parent.pos.x+parent.dim.w/2
  local dy = dy-parent.pos.y+parent.dim.h/2
  local angle = math.sqrt(dx*dx+dy*dy)
  local vel_x = (dx/angle)*(200+math.abs(parent.vel.x*1.25))
  local vel_y = (dy/angle)*(200+math.abs(parent.vel.y*1.25))
  self.vel      = {x=vel_x or 0,y=vel_y or 0,lx=260,ly=260}
  self.filter = function(self, other)
    if other == parent then return "cross"
    elseif not other.solid then return
    else return "bounce" end
  end
  -- Additional
  self:newSprite(self.type, Assets.spritesheet, Assets.getAnimation(self.type))
  self:setSprite(self.type)
end


function Bomb:onCollision(other)
  if other.name == "lava" then self:destroy() end
end


function Bomb:onDead()
  Assets.playSound("boom")
  Screen:shake()
  for i=1, math.random(20,25) do
    self.level:spawn("particle", self.pos.x, self.pos.y)
  end
  local radius = 24
  local x = self.pos.x+self.dim.w/2-radius/2
  local y = self.pos.y+self.dim.h/2-radius/2
  local cols = self.level.collisionWorld:queryRect(x, y, radius, radius)
  for i=1, #cols do
    local other = cols[i]
    if other.canDie then
      Assets.playSound("splat")
      other:onDead(self)
    end
  end
  self:destroy()
end


function Bomb:logic(dt)
  self:accelerate(dt)
end

return Bomb
