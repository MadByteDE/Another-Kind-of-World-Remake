

local Element = Class()
Element:include(Object)


function Element:init(x, y, t)
  Object.init(self, x, y, t)
  self.type       = "element"
  self.tooltip    = self.tooltip or "No info available"
  self.text       = self.text or self.type
  self.collide    = self.collide or true
  self.draggable  = self.draggable or false
  self.selectable = self.selectable or false
  self.selected   = false
  self.dragged    = false
  self.diff       = {x=0, y=0}
  self.timeout    = self.timeout or 0
  if self.timeout > 0 then
    self.timer = self.timeout
  end
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

function Element:onSelect()
  self.selected = true
end

function Element:onDeselect()
  self.selected = false
end

function Element:setTimeout(timeout)
  self.timeout = timeout or 0
  self.timer = self.timeout
end

function Element:onScroll(x, y) end

function Element:onTimeout() end

function Element:onTextInput(text)
  self.text = self.text .. text
end

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

  if self.timeout > 0 then
    self.timer = self.timer - dt
    if self.timer <= 0 then
      self:onTimeout()
      if self.selected then self.gui:deselect(self) end
      self.timer = 0
      self.timeout = 0
    end
  end

  self:logic(dt)
end

return Element
