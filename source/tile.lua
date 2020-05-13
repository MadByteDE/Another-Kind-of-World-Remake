
local lg = love.graphics

local Assets  = require("source.assets")
local Actor   = require("source.actor")
local Class   = require("source.lib.class")
local Tile    = Class()
Tile:include(Actor)


function Tile:init(world, x, y, w, t)
  Actor.init(self, world, x, y, t)
  if self.anim then
    self.anim = self.anim:clone()
    if t.randomFrame then
      self.anim:gotoFrame(love.math.random(1, #self.anim.frames))
    end
  end
end


function Tile:update(dt)
  if self.anim then self.anim:update(dt) end
end


function Tile:draw()
  if not self.visible then return end
  if self.quad then lg.draw(Assets.tileset.image, self.quad, self.pos.x, self.pos.y)
  elseif self.anim then self.anim:draw(Assets.tileset.image, self.pos.x, self.pos.y) end
  --self:drawRectangle("line")
end

return Tile
