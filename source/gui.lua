
local elements = {
  ["mouse"]  = require("source.gui.mouse"),
  ["button"] = require("source.gui.button"),
}

local function aabb(a, b)
  return a.pos.x + a.dim.w > b.pos.x and a.pos.x < b.pos.x + b.dim.w and
  a.pos.y + a.dim.h > b.pos.y and a.pos.y < b.pos.y + b.dim.h
end


local Gui = Class()


function Gui:init()
  self.elements = Conta()
  self.mouse    = elements["mouse"]()
end


function Gui:add(name, x, y, t)
  return self.elements:add(elements[name](x, y, t))
end


function Gui:getMouse()
  return self.mouse
end


function Gui:update(dt)
  self.mouse:update(dt)
  self.elements:update(dt)
  self.elements:iterate(function(k, v)
    if not v.collides then return end
    local col = aabb(self.mouse, v)
    if col then self.mouse.hover = true
    else self.mouse.hover = false end
    if not v.parent and col then
      self.mouse.child = v
      v.parent = self.mouse
      v:onEnter(v.parent)
    elseif v.parent and not col then
      v:onExit(v.parent)
      v.parent = nil
      self.mouse.child = nil
    end
  end)
end


function Gui:draw()
  self.elements:draw()
  self.mouse:draw()
end


function Gui:mousepressed(x, y, button)
  local child = self.mouse.child
  if child then child:onClick(self.mouse, button) end
end


function Gui:mousereleased(x, y, button)
  if child then child:onRelease(self.mouse, button) end
end

return Gui
