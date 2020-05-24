
local Tile = Class()
Tile:include(Object)
local tw = Assets.tilesize

function Tile:init(world, x, y, tile)
  for k,v in pairs(tile) do self[k] = v end
  Object.init(self, x, y, {dim={w=tw, h=tw}})
  if world and self.collides then self:addCollider(world.collisionWorld) end
  if self.type == "animatedTile" then
    self:newSprite(self.name, Assets.spritesheet, Assets.getAnimation(self.name))
    self:setSprite(self.name)
    if self.randomFrame then
      self.sprite:gotoFrame(love.math.random(1, #self.sprite.frames))
    end
  else
    self:newSprite(self.name, Assets.spritesheet, self.quad)
    self:setSprite(self.name)
  end
end

return Tile
