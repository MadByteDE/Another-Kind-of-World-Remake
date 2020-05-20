
local Exit = Class()
Exit:include(Object)
local tw      = Assets.getTilesize()
local iw, ih  = Assets.tilesheet:getDimensions()


function Exit:init(world, x, y)
  Object.init(self, x, y)
  self.world    = world
  self.type     = "exit"
  self.visible  = false
  self:newSprite("exit", Assets.tilesheet, lg.newQuad(tw*4, 0, tw, tw, iw, ih))
  self:setSprite("exit")
end


function Exit:logic(dt)
  if not self.visible and #self.world.objects:get("bug") == 0 then
    self.visible  = true
    self.collides = true
    self:addCollider(self.world.collisionWorld)
  end
end

return Exit
