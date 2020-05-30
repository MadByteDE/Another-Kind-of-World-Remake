
local Gui = Class()


local function aabb(a, b)
  return a.pos.x + a.dim.w > b.pos.x and a.pos.x < b.pos.x + b.dim.w and
  a.pos.y + a.dim.h > b.pos.y and a.pos.y < b.pos.y + b.dim.h
end


function Gui:init()
  self.elements = Conta()
  self.mouse = Elements.mouse()
end


function Gui:add(name, x, y, t)
  local t = t or {}
  t._gui=self
  local element = Elements[name](x, y, t)
  return self.elements:add(element)
end


function Gui:getMouse()
  return self.mouse
end


function Gui:update(dt)
  self.mouse:update(dt)
  self.elements:update(dt)
  self.elements:iterate(function(k, other)
    if not other.collide then return end
    local mouse = self.mouse
    local col = aabb(mouse, other)
    if col then
      if mouse.child == other.parent or not mouse.child then
        mouse.child = other
        mouse.child:onEnter(mouse)
      end
    elseif not col and other == mouse.child then
      mouse.child:onExit(mouse)
      mouse.child = nil
    end
  end)
end


function Gui:draw()
  self.elements:draw()
  self.mouse:draw()
end


function Gui:mousepressed(x, y, button)
  self.mouse:mousepressed(x, y, button)
end


function Gui:mousereleased(x, y, button)
  self.mouse:mousereleased(x, y, button)
end


function Gui:wheelmoved(x, y)
  self.mouse:wheelmoved(x, y)
end

return Gui
