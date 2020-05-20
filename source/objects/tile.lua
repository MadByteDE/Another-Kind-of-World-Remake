
local Tile = Class()
Tile:include(Object)


function Tile:init(world, x, y, tile)
  for k,v in pairs(tile) do self[k] = v end
  local tw = Assets.getTilesize()
  Object.init(self, x, y, {dim={w=tw, h=tw}})
  if self.collides then self:addCollider(world.collisionWorld) end
  if self.anim then
    self.anim = self.anim:clone()
    if self.randomFrame then
      self.anim:gotoFrame(love.math.random(1, #self.anim.frames))
    end
  end
end


function Tile:update(dt)
  if self.anim then self.anim:update(dt) end
end


function Tile:draw()
  if not self.visible then return end
  if self.anim then self.anim:draw(Assets.tilesheet, self.pos.x, self.pos.y)
  elseif self.quad then lg.draw(Assets.tilesheet, self.quad, self.pos.x, self.pos.y) end
end

return Tile
