
local Object = Class()


function Object:init(world, x, y, t)
  local t = t or {}
  for k,v in pairs(t) do self[k] = v end
  self.world    = world
  self.pos      = self.pos or {x=x or 0, y=y or 0}
  self.type     = self.type or "object"
  self.rgba     = self.rgba or {1, 1, 1, 1}
  self.dim      = self.dim or {w=8, h=8}
  self.trans    = self.trans or {r=0, sx=1, sy=1, ox=0, oy=0}
  self.visible  = self.visible or true
  self.isSolid  = self.isSolid or false
  self.collides = self.collides or false
  self.sprites  = self.sprites or {}
  self.sprite   = self.sprite or nil
  if self.collides then self:addCollider() end
end


function Object:newQuad(name, image, data)
  local sprite = {}
  sprite.image = image
  sprite.update = function()end
  sprite.draw = function(self, image, ...) lg.draw(self.image, self.quad, ...)end
  if type(data) == "table" then
    sprite.quad = Assets.newQuad(data)
  else sprite.quad = data end
  self.sprites[name] = sprite
  return sprite
end


function Object:newAnimation(name, image, data)
  local sprite = Assets.newAnimation(data)
  sprite.image = image
  self.sprites[name] = sprite
  return sprite
end


function Object:setSprite(name)
  self.sprite = self.sprites[name]
end


function Object:addCollider(colWorld)
  self.collisionWorld = colWorld or self.world.collisionWorld
  if self.collisionWorld:hasItem(self) then return end
  -- default collision filter
  self.filter = self.filter or function(self, other)
    if self.isSolid and other.isSolid then return "slide"
    else return "cross" end
  end
  -- Create collider
  local x, y = self.pos.x, self.pos.y
  local w, h = self.dim.w, self.dim.h
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


function Object:update(dt)
  if self._flags.removed then return end
  -- update the sprite / animation
  if self.sprite then
    self.sprite:update(dt)
  end
  -- update additional game logic
  if self.logic then self:logic(dt) end
end


function Object:draw()
  if self.visible and self.sprite then
    local r = self.trans.r
    local x, y = self.pos.x, self.pos.y
    local sx, sy = self.trans.sx, self.trans.sy
    local ox, oy = self.trans.ox, self.trans.oy
     self.sprite:draw(self.sprite.image, x, y, r, sx, sy, ox, oy)
  end
  if self.render then self:render() end
end

return Object
