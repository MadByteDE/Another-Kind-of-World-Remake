
local Bomb = Class()
Bomb:include(Actor)


function Bomb:init(world, dx, dy, parent)
  local x = parent.pos.x+parent.dim.w/2-3
  local y = parent.pos.y+parent.dim.h/2-3
  local dx = dx-parent.pos.x
  local dy = dy-parent.pos.y
  local angle = math.sqrt(dx*dx+dy*dy)
  local vel_x = (dx/angle)*(200+math.abs(parent.vel.x*1.25))
  local vel_y = (dy/angle)*(200+math.abs(parent.vel.y*1.25))
  Actor.init(self, world, x, y, {collides=true})
  self.type     = "bomb"
  self.parent   = parent
  self.dim      = {w=6, h=6}
  self.trans    = {r=0, sx=1, sy=1, ox=.5, oy=2}
  self.vel      = {x=vel_x or 0,y=vel_y or 0,lx=300,ly=300}
  self.damp     = {x=3,y=2}
  self.gravity  = 30
  self.lifetime = 3.5
  self.bounciness = .6
  self.filter = function(self, other)
    if other == parent or other.type == "bomb" then return "cross"
    elseif not other.isSolid then return
    else return "bounce" end
  end

  self:newSprite("lit", '4-7', 3, .1)
  self:setSprite("lit")
  Assets.audio.play("toss", .65)
end


function Bomb:onDead()
  Assets.audio.play("boom", .5)
  Screen:shake()
  for i=1, math.random(20,25) do
    self.world:spawn("particle", self.pos.x, self.pos.y)
  end
  local radius = 24
  local ex = self.pos.x+(self.dim.w/2)-radius/2
  local ey = self.pos.y+(self.dim.h/2)-radius/2
  local cols = self.world.collisionWorld:queryRect(ex, ey, radius, radius)
  for i=1, #cols do
    local other = cols[i]
    if other.canDie then
      Assets.audio.play("splat", .6)
      other:onDead()
    end
  end
  self:destroy()
end


function Bomb:logic(dt)
  self:accelerate(dt)
end

return Bomb
