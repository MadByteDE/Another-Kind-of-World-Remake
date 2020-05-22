
local Button = Class()
Button:include(Element)


function Button:init(x, y, t)
  Element.init(self, x, y, t)
  self.type = "button"
  self.rgba = {.8, .8, .8, .75}
  if self.quad then
    self:newSprite(self.type, Assets.spritesheet, self.quad)
    self:setSprite(self.type)
    local _, _, qw, qh = self.quad:getViewport()
    self.dim = {w=qw, h=qh}
  end
  self.action = self.action or function() end
end


function Button:onEnter()
  self.rgba = {1, 1, 1, 1}
end


function Button:onExit()
  self.rgba = {.8, .8, .8, .75}
end


function Button:onClick(button)
  self.rgba = {.45, .45, .45, 1}
  self.action(button)
end


function Button:onRelease(button)
  self.rgba = {1, 1, 1, 1}
end


return Button
