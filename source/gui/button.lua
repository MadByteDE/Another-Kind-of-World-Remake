
local Button = Class()
Button:include(Object)


function Button:init(x, y, t)
  Object.init(self, x, y, t)
  self.type     = "button"
  self.collides = true
  self.parent   = nil
  self.text     = self.text or "notext"
  self.action   = self.action or function() end
end


function Button:onEnter(mouse)
  self.rgba = {1, 0, 0, 1}
end


function Button:onExit(mouse)
  self.rgba = {1, 1, 1, 1}
end


function Button:onClick(mouse, button)
  if button == 1 then self:action(mouse) end
end


function Button:onRelease(mouse, button)
end


function Button:logic(dt)
end


function Button:render()
  if self.parent then -- Mouse hover the button
    -- Draw highlight frame
  end
  self:drawRectangle("line") --Debug
end

return Button
