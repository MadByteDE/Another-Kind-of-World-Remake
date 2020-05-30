
local Tile = Class()
Tile:include(Object)
local tw = Assets.tilesize

function Tile:init(world, x, y, tile)
  for k,v in pairs(tile or {}) do self[k] = v end
  -- Init
  Object.init(self, x, y, {dim=tile.dim or {w=tw, h=tw}})
  -- Additional
  -- Remove properties used for the entity
  if self.type == "entity" then
    self.collide = false
    self.solid = false
  end
  -- Add collider
  if world and self.collide then self:addCollider(world.collisionWorld) end
  -- Add sprite
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
