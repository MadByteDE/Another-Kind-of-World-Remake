
local Button = Class()
Button:include(Object)


function Button:init(x, y, t)
  Object.init(self, x, y, t)
  self.text   = self.text or "notext"
  self.action = self.action or function()end
end


function Button:logic(dt)
end


function Button:render()
end

return Button
