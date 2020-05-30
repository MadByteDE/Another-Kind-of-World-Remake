
local Exit = Class()
Exit:include(Object)


function Exit:init(world, x, y, tile)
  -- Init
  Object.init(self, x, y, tile)
  self.world    = world
  self.type     = "exit"
  self.visible  = false
  -- Additional
  self:newSprite(self.type, Assets.spritesheet, self.quad)
  self:setSprite(self.type)
end


function Exit:logic(dt)
  if not self.visible and #self.world.objects:get("bug") == 0 then
    self.visible = true
    self.collide = true
    self:addCollider(self.world.collisionWorld)
  end
end

return Exit
