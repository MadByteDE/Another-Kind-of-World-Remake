
local Object = Class()


function Object:init(x, y, t)
  for k,v in pairs(t or {}) do self[k] = v end
  -- Core
  self.type     = self.type or "object"
  self.trans    = self.trans or {r=0, sx=1, sy=1, ox=0, oy=0}
  self.dim      = self.dim or {w=8, h=8}
  self.pos      = {x=x+self.trans.ox or 0, y=y+self.trans.oy or 0}
  self.rgba     = self.rgba or {1, 1, 1, 1}
  -- Properties
  self.visible  = self.visible or true
  self.deadly   = self.deadly or false
  self.solid    = self.solid or false
  self.collide  = self.collide or false
  self.sprites  = self.sprites or {}
  -- Undeclared
  self.sprite   = self.sprite or nil
  self.collider = self.collider or nil
  self._flags   = self._flags or nil
end


function Object:newSprite(name, image, data)
  local sprite = {}
  sprite.name = name or "Sprite"
  sprite.type = "Quad"
  sprite.update = function(dt)end
  sprite.draw = function(self, image, ...)
    lg.draw(image or self.image, self.quad, ...)
  end
  if type(data) == "table" then sprite = data
  else sprite.quad = data end
  sprite.image = image
  self.sprites[name] = sprite
  return sprite
end


function Object:setSprite(name)
  self.sprite = self.sprites[name] or self.sprite
end


function Object:filter(other)
  if self.solid and other.solid then return "slide"
  else return "cross" end
end


function Object:addCollider(collisionWorld, x, y, w, h)
  self.collisionWorld = collisionWorld
  if self.collider then return end
  local x, y, w, h = self:getRect()
  self.collisionWorld:add(self, x, y, w, h, self.filter)
  self.collider = self.collisionWorld:getRect(self)
end


function Object:removeCollider()
  if self.collider then
    self.collisionWorld:remove(self)
    self.collider = nil
  end
end


function Object:updateCollider()
  if self.collider then
    local x, y, w, h = self:getRect()
    self.collisionWorld:update(self, x, y, w, h)
  end
end


function Object:getRect(x, y, w, h)
  local x, y = x or self.pos.x, y or self.pos.y
  local w, h = w or self.dim.w, h or self.dim.h
  return x, y, w, h
end


function Object:drawRectangle(mode)
  lg.setColor(self.rgba)
  lg.rectangle(mode or "fill", self.pos.x, self.pos.y, self.dim.w, self.dim.h)
  lg.setColor(1, 1, 1, 1)
end


function Object:destroy()
  self._flags.removed = true -- Conta lib removal
  self:removeCollider()
end


function Object:logic(dt) end


function Object:update(dt)
  if self._flags and self._flags.removed then return end
  -- update additional game logic
  self:logic(dt)
  -- update the sprite / animation
  if self.sprite then self.sprite:update(dt) end
end


function Object:render() end


function Object:draw()
  if self.visible and self.sprite then
    local r = self.trans.r
    local x, y = self:getRect()
    local sx, sy = self.trans.sx, self.trans.sy
    local ox, oy = self.trans.ox, self.trans.oy
    lg.setColor(self.rgba)
    self.sprite:draw(self.sprite.image, x, y, r, sx, sy, ox, oy)
    lg.setColor(1, 1, 1, 1)
  end
  self:render()
end

return Object
