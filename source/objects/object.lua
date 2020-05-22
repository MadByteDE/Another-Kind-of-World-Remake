
local Object = Class()


function Object:init(x, y, t)
  for k,v in pairs(t or {}) do self[k] = v end
  self.pos      = {x=x or 0, y=y or 0}
  self.dim      = self.dim or {w=8, h=8}
  self.type     = self.type or "object"
  self.rgba     = self.rgba or {1, 1, 1, 1}
  self.trans    = self.trans or {r=0, sx=1, sy=1, ox=0, oy=0}
  self.visible  = self.visible or true
  self.isSolid  = self.isSolid or false
  self.collides = self.collides or false
  self.sprites  = self.sprites or {}
  self.sprite   = self.sprite or nil
end


function Object:newSprite(name, image, data)
  print(name)
  local sprite = {}
  sprite.name = name or "Sprite"
  sprite.type = "Quad"
  sprite.update = function(dt)end
  sprite.draw = function(self, image, ...)
    lg.draw(image or self.image, self.quad, ...)
  end
  if type(data) == "table" then
    sprite = data
  else sprite.quad = data end
  sprite.image = image
  self.sprites[name] = sprite
  return sprite
end


function Object:setSprite(name)
  self.sprite = self.sprites[name] or self.sprite
end


function Object:addCollider(collisionWorld, x, y, w, h)
  self.collisionWorld = collisionWorld
  if self.collisionWorld:hasItem(self) then return end
  -- default collision filter
  self.filter = self.filter or function(self, other)
    if self.isSolid and other.isSolid then return "slide"
    else return "cross" end
  end
  -- Create collider
  local x, y = x or self.pos.x, y or self.pos.y
  local w, h = w or self.dim.w, h or self.dim.h
  self.collisionWorld:add(self, x, y, w, h, self.filter)
end


function Object:removeCollider()
  if self.collisionWorld and self.collisionWorld:hasItem(self) then
    self.collisionWorld:remove(self)
  end
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
    local x, y = self.pos.x, self.pos.y
    local sx, sy = self.trans.sx, self.trans.sy
    local ox, oy = self.trans.ox, self.trans.oy
    lg.setColor(self.rgba)
    self.sprite:draw(self.sprite.image, x, y, r, sx, sy, ox, oy)
    lg.setColor(1, 1, 1, 1)
  end
  self:render()
end

return Object
