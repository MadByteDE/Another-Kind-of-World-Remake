
local Mouse = Class()
Mouse:include(Element)


function Mouse:init(x, y, t)
  local mx, my = self:getPosition(x, y)
  Element.init(self, mx, my, t)
  self.type     = "mouse"
  self.dim      = {w=1, h=1}
  self:newSprite(self.type, Assets.spritesheet, Assets.getQuad("sprite", {7, 2}))
  self:setSprite(self.type)
  local _, _, qw, qh = self.sprite.quad:getViewport()
  self.trans.ox = qw/2
  self.trans.oy = qh/2
  self.button = 0
  self.scroll = {x=0, y=0}
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
  if not love.mouse.isDown(self.button) then self.button = 0 end
end


function Mouse:mousepressed(x, y, button)
  if self.child then
    local x, y = self:getPosition()
    self.child:onClick(button, x, y)
    if self.child.selectable then self.gui:select(self.child) end
  else
    self.button = button
  end
  if self.gui.selectedElement and self.gui.selectedElement ~= self.child then
    self.gui:deselect(self.gui.selectedElement)
  end
end


function Mouse:mousereleased(x, y, button)
  if self.child then
    local x, y = self:getPosition()
    self.child:onRelease(button, x, y)
  else
    self.button = button
  end
end


function Mouse:wheelmoved(x, y)
  if self.child then
    self.child:onScroll(x, y)
  else
    self.scroll.x = x
    self.scroll.y = y
  end
end

return Mouse
