
local lg = love.graphics

local Assets  = require("source.assets")
local Actor   = require("source.actor")
local Class   = require("source.lib.class")
local Tile    = Class()
Tile:include(Actor)


function Tile:init(world, x, y, w, t)
  Actor.init(self, world, x, y, t)
  self.anim = t.anim
  self.quad = t.quad
end


function Tile:update(dt)
  if self.anim then self.anim:update(dt) end
end


function Tile:draw()
  if not self.visible then return end
  if self.quad then lg.draw(Assets.tileset.image, self.quad, self.pos.x, self.pos.y)
  elseif self.anim then self.anim:draw(Assets.sprite.image, self.pos.x, self.pos.y) end
  --self:drawRectangle("line")
end

return Tile
