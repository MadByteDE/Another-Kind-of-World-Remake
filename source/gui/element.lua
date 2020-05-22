

local Element = Class()
Element:include(Object)


function Element:init(x, y, t)
  Object.init(self, x, y, t)
  self.type     = "element"
  self.text     = self.text or self.type
  self.collides = self.collides or true
  self.dragged  = self.dragged or false
  self.tooltip  = self.tooltip or "No info available"
  self.parent   = self.parent or nil
  self.child    = self.child or nil
end


function Element:onEnter() end

function Element:onExit() end

function Element:onClick(button) end

function Element:onRelease(button) end

function Element:onScroll(x, y) end

return Element
