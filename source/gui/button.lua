
local Button = Class()
Button:include(Object)


function Button:init(x, y, t)
  Object.init(self, x, y, t)
  self.type     = "button"
  self.collides = true
  self.rgba     = {.8, .8, .8, .75}
  self.parent   = self.parent or nil
  if self.quad then
    self:newSprite("default", Assets.buttonsheet, self.quad)
    self:setSprite("default")
    local _, _, qw, qh = self.quad:getViewport()
    self.dim = {w=qw, h=qh}
  end
  self.text   = self.text or "notext"
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
  self.rgba = {.8, .8, .8, .75}
end


return Button
