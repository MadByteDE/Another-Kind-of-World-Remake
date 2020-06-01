
local Exit = Class()
Exit:include(Object)


function Exit:init(level, x, y, tile)
  -- Init
  Object.init(self, x, y, tile)
  self.level    = level
  self.type     = "exit"
  self.visible  = false
  -- Additional
  self:newSprite(self.type, Assets.spritesheet, self.quad)
  self:setSprite(self.type)
end


function Exit:logic(dt)
  if not self.visible and #self.level.objects:get("bug") == 0 then
    self.visible = true
    self.collide = true
    self:addCollider(self.level.collisionWorld)
  end
end

return Exit
