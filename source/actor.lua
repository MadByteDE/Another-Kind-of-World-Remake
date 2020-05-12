
local lg = love.graphics

local function clamp(val, min, max)
  if not val then return end
  return math.min(math.max(val, min), max)
end

local Screen  = require("source.screen")
local Assets  = require("source.assets")
local Class   = require("source.lib.class")
local Actor   = Class()


function Actor:init(world, x, y, t)
  local t = t or {}
  for k,v in pairs(t) do self[k] = v end
  self.world    = world
  self.pos      = self.pos or {x=x or 0, y=y or 0}
  self.type     = self.type or "actor"
  self.rgba     = self.rgba or {1, 1, 1, 1}
  self.dim      = self.dim or {w=7, h=7}
  self.trans    = self.trans or {r=0, sx=1, sy=1, ox=0, oy=0}
  self.vel      = self.vel or {x=0, y=0, lx=150, ly=150}
  self.acc      = self.acc or {x=50, y=50}
  self.gravity  = self.gravity or 0
  self.damp     = self.damp or {x=0, y=0}
  self.dir      = self.dir or {x=0, y=0}
  self.isSolid  = self.isSolid or false
  self.collides = self.collides or false
  self.bounciness = self.bounciness or 0
  self.noWrap   = self.noWrap or false
  self.isAI     = self.isAI or false
  self.lifetime = clamp(self.lifetime, 0, 999)
  self.visible  = self.visible or true
  self.sprites  = self.sprites or {}
  self.sprite   = self.sprite or nil
  self.inAir    = self.inAir or false
  self.dead     = false

  if self.collides then
    self.collisionWorld = world.collisionWorld
    -- default collision filter
    self.filter = self.filter or function(self, other)
      if self.bounciness > 0 then return "bounce"
      elseif self.isSolid and other.isSolid then return "slide"
      else return "cross" end
    end
    -- Create collider
    local x, y = self.pos.x, self.pos.y
    local w, h = self.dim.w, self.dim.h
    self.collisionWorld:add(self, x, y, w, h, self.filter)
  end
end


function Actor:newAnimation(name, frames, row, durations, onLoop)
  self.sprites[name] = Assets.newAnimation(frames, row, durations, onLoop)
  return self.sprites[name]
end


function Actor:setAnimation(name)
  self.sprite = self.sprites[name]
end


function Actor:setDamping(x, y)
  self.damp.x = clamp(x or 0, 0, 100)
  self.damp.y = clamp(y or 0, 0, 100)
end


function Actor:move(dt)
  local dx,dy = self.dir.x, self.dir.y
  -- x-axis
  if dx ~= 0 then self.vel.x = (self.acc.x * dx * 10) * dt
  else if self.damp.x > 0 then
    self.vel.x = self.vel.x / (1 + self.damp.x * dt)
    else self.vel.x = 0 end
  end
  -- y axis
  if dy ~= 0 then self.vel.y = (self.acc.y * dy * 10) * dt
  else if self.damp.y > 0 then
    self.vel.y = self.vel.y / (1 + self.damp.y * dt)
    else self.vel.y = 0 end
  end
end


function Actor:accelerate(dt)
  local dx,dy = self.dir.x, self.dir.y
  -- x-axis
  if dx ~= 0 then self.vel.x = self.vel.x + (self.acc.x * dx * 10) * dt
  else self.vel.x = self.vel.x / (1 + self.damp.x * dt) end
  -- y-axis
  if dy ~= 0 then self.vel.y = self.vel.y + (self.acc.y * dy * 10) * dt
  else self.vel.y = self.vel.y / (1 + self.damp.y * dt) end
end


function Actor:applyGravity(dt)
  self.vel.y = self.vel.y + self.gravity * 10 * dt
end


function Actor:jump(vel)
  if not self.inAir then
    self.inAir = true
    self.vel.y = vel or -self.acc.y
  end
end


function Actor:drawRectangle(mode)
  lg.setColor(self.rgba)
  lg.rectangle(mode or "fill", self.pos.x, self.pos.y, self.dim.w, self.dim.h)
  lg.setColor(1, 1, 1, 1)
end


function Actor:onDead()
  self:destroy()
end


function Actor:destroy()
  self._flags.removed = true -- Conta lib removal
  if self.collisionWorld and self.collisionWorld:hasItem(self) then
    self.collisionWorld:remove(self)
  end
end


function Actor:update(dt)
  if self._flags.removed then return end
  -- wrap around the screen
  if not self.noWrap then
    if self.pos.x > Screen.width then self.pos.x = -self.dim.w+2
    elseif self.pos.x < -self.dim.w then self.pos.x = Screen.width-2 end
    if self.pos.y > Screen.height then self.pos.y = -self.dim.h+2
    elseif self.pos.y < -self.dim.h then self.pos.y = Screen.height-2 end
    if self.collisionWorld and self.collisionWorld:hasItem(self) then
      self.collisionWorld:update(self, self.pos.x, self.pos.y, self.dim.w, self.dim.h)
    end
  end
  -- Update lifetime
  if self.lifetime then
    self.lifetime = self.lifetime-dt
    if self.lifetime <= 0 then
      self:onDead()
      self.lifetime = nil
    end
  end
  -- Add gravity
  self:applyGravity(dt)
  -- clamp speed to set limits
  self.vel.x = clamp(self.vel.x, -self.vel.lx, self.vel.lx)
  self.vel.y = clamp(self.vel.y, -self.vel.ly, self.vel.ly)
  -- calculate position
  local x = self.pos.x + self.vel.x * dt
  local y = self.pos.y + self.vel.y * dt
  -- Resolve collisions & update position
  if self.collisionWorld and self.collisionWorld:hasItem(self) then
    -- AI movement on platform (pretty expensive to use & ugly :/)
    if self.isAI then
      local left  = self.collisionWorld:queryPoint(x-1, y+(self.dim.h/2), self.filter)
      local right = self.collisionWorld:queryPoint(x+self.dim.w+1, y+(self.dim.h/2), self.filter)
      local downLeft  = self.collisionWorld:queryRect(x-3, y+self.dim.h, 2, 2, self.filter)
      local downRight  = self.collisionWorld:queryRect(x+self.dim.w, y+self.dim.h, 2, 2, self.filter)
      if self.dir.x > 0 and #downRight==0 or #right > 0 then self.dir.x = -1
      elseif self.dir.x < 0 and #downLeft==0 or #left > 0 then self.dir.x = 1 end
    end
    local cols
    self.pos.x, self.pos.y, cols = self.collisionWorld:move(self, x, y, self.filter)
    for k,col in ipairs(cols) do
      -- Reset velocities
      if col.type == "slide" then
        if col.other.pos.y == self.pos.y + self.dim.h then
          self.vel.y = 0
          self.inAir = false
        elseif col.other.pos.y + col.other.dim.h == self.pos.y then
          self.vel.y = 0
        end
        if col.normal.x ~= 0 then
          self.vel.x = 0
        end
      end
      -- Apply bounciness
      if col.type == "bounce" then
        local nx, ny = col.normal.x, col.normal.y
        if (nx < 0 and self.vel.x > 0) or (nx > 0 and self.vel.x < 0) then
          self.vel.x = -self.vel.x * self.bounciness
        end
        if (ny < 0 and self.vel.y > 0) or (ny > 0 and self.vel.y < 0) then
          self.vel.y = -self.vel.y * self.bounciness
        end
      end
      -- Apply additional changes if specified
      if self.onCollision then self:onCollision(col) end
    end
  else
    self.pos.x, self.pos.y = x, y
  end
  -- update the sprite / animation
  if self.sprite then self.sprite:update(dt) end
  -- update additional game logic
  if self.logic then self:logic(dt) end
end


function Actor:draw()
  if self.visible and self.sprite then
    local r = self.trans.r
    local x, y = self.pos.x, self.pos.y
    local sx, sy = self.trans.sx, self.trans.sy
    local ox, oy = self.trans.ox, self.trans.oy
    self.sprite:draw(Assets.sprite.image, x, y, r, sx, sy, ox, oy)
  end
  if self.render then self:render() end
end

return Actor
