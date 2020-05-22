
local Tilepanel = Class()
Tilepanel:include(Element)


function Tilepanel:init(x, y, t)
  Element.init(self, x, y, t)
  self.type   = "tilepanel"
  self.tiles  = Assets.getTiles()
  
end


function Tilepanel:onClick(button)
end


function Tilepanel:onRelease(button)
end


function Element:onScroll(x, y)
end


function Tilepanel:logic(dt)
end


function Tilepanel:render()
end

return Tilepanel
