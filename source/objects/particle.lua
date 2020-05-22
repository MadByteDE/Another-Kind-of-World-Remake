
local Particle = Class()
Particle:include(Actor)
local quads = { -- not flexible that way - need to change that!
  Assets.getQuad("sprite", {1, 3}),
  Assets.getQuad("sprite", {2, 3}),
  Assets.getQuad("sprite", {3, 3}),
}


function Particle:init(world, x, y, quad)
  Actor.init(self, world, x, y)
  self.noWrap   = true
  self.gravity  = 40
  self.lifetime = .4
  self.pos.x    = self.pos.x - love.math.random(-12, 12)
  self.pos.y    = self.pos.y - love.math.random(-12, 12)
  self.trans    = {r=love.math.random(-24, 24), sx=1, sy=1, ox=self.dim.w/2, oy=self.dim.h/2}
  self.vel      = {x=love.math.random(-10, 10), y=-love.math.random(30, 60), lx=100, ly=100}
  self.quad     = quads[quad or math.random(1, 3)]
end


function Particle:logic(dt)
  self.trans.r = self.trans.r + (self.vel.x/2) * dt
end


function Particle:render()
  local r = self.trans.r
  local x, y = self.pos.x, self.pos.y
  local sx, sy = self.trans.sx, self.trans.sy
  local ox, oy = self.trans.ox, self.trans.oy
  lg.draw(Assets.spritesheet, self.quad, x, y, r, sx, sy, ox, oy)
end

return Particle
