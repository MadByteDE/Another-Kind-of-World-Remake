
local Mouse = Class()
Mouse:include(Element)


function Mouse:init(x, y, t)
  local mx, my = self:getPosition(x, y)
  Element.init(self, mx, my, t)
  self.type     = "mouse"
  self.dim      = {w=1, h=1}
  self:newSprite(self.type, Assets.spritesheet, Assets.getQuad("sprite", {7, 2}))
  -- self:newSprite("hover", Assets.spritesheet, Assets.newQuad({7, 2}))
  self:setSprite(self.type)
  local _, _, qw, qh = self.sprite.quad:getViewport()
  self.trans.ox = qw/2
  self.trans.oy = qh/2
end


function Mouse:setPosition(x, y)
  love.mouse.setPosition(x*Screen.scale, y*Screen.scale)
end


function Mouse:getPosition()
  local mx, my = love.mouse.getPosition()
  return mx/Screen.scale, my/Screen.scale
end


function Mouse:logic(dt)
  self.pos.x, self.pos.y = self:getPosition()
end


function Mouse:mousepressed(x, y, button)
  if self.child then
    local x, y = self:getPosition()
      print("PRESS")
    self.child:onClick(button, x, y)
  end
end


function Mouse:mousereleased(x, y, button)
  if self.child then
    local x, y = self:getPosition()
    print("RELEASE")
    self.child:onRelease(button, x, y)
  end
end


function Mouse:wheelmoved(x, y)
  if self.child then
    self.child:onScroll(x, y)
  end
end

return Mouse
