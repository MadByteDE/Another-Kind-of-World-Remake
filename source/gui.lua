
local Gui = Class()

local elements = {
  ["button"]    = require("source.gui.button"),
  ["tilepanel"] = require("source.gui.tilepanel"), }

local function aabb(a, b)
  return a.pos.x + a.dim.w > b.pos.x and a.pos.x < b.pos.x + b.dim.w and
  a.pos.y + a.dim.h > b.pos.y and a.pos.y < b.pos.y + b.dim.h
end


function Gui:init()
  self.elements = Conta()
  self.mouse    = Mouse()
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
  self.elements:iterate(function(k, other)
    if not other.collides then return end
    local mouse = self.mouse
    local col = aabb(mouse, other)
    if not other.parent and col then
      mouse.child = other
      other.parent = self.mouse
      mouse:onEnter()
      other:onEnter()
    elseif other.parent and not col then
      other:onExit()
      mouse:onExit()
      other.parent = nil
      mouse.child = nil
    end
  end)
end


function Gui:draw()
  self.elements:draw()
  self.mouse:draw()
end


function Gui:mousepressed(x, y, button)
  if self.mouse.child then self.mouse.child:onClick(button) end
end


function Gui:mousereleased(x, y, button)
  if self.mouse.child then self.mouse.child:onRelease(button) end
end


function Gui:wheelmoved(x, y)
  if self.mouse.child then self.mouse.child:onScroll(button) end
end

return Gui
