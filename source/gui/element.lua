

local Element = Class()
Element:include(Object)


function Element:init(x, y, t)
  Object.init(self, x, y, t)
  self.type       = "element"
  self.text       = self.text or self.type
  self.collides   = self.collides or true
  self.draggable  = self.draggable or false
  self.dragged    = false
  self.diff       = {x=0, y=0}
  self.tooltip    = self.tooltip or "No info available"
end


function Element:onEnter()
end

function Element:onExit()
end

function Element:onClick(button, x, y)
  if self.draggable and button == 1 then
    self.dragged = true
    self.diff = {x=x-self.pos.x, y=y-self.pos.y}
  end
end

function Element:onRelease(button, x, y)
  if self.dragged then
    self.dragged = false
    self.diff = {x=0, y=0}
  end
end

function Element:onScroll(x, y) end

function Element:update(dt)
  local mouse = CurrentScene:getMouse()
  if self.parent then
    if self.parent.dragged and not self.dragged then
      self.dragged = true
      self.diff = {x=mouse.pos.x-self.pos.x, y=mouse.pos.y-self.pos.y}
    elseif not self.parent.dragged and self.dragged then
      self.dragged = false
      self.diff = {x=0, y=0}
    end
  end
  if self.dragged then
    self.pos.x = mouse.pos.x-self.diff.x
    self.pos.y = mouse.pos.y-self.diff.y
  end
  self:logic(dt)
end

return Element
