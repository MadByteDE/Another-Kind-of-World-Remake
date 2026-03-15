-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Gui = Class()

local elements  = {
    mouse      = require("gui.mouse"),
    button     = require("gui.button"),
    textbox    = require("gui.textbox"),
    tilepanel  = require("gui.tilepanel")
}


local function aabb(a, b)
    return a.pos.x + a.dim.w > b.pos.x and a.pos.x < b.pos.x + b.dim.w and
    a.pos.y + a.dim.h > b.pos.y and a.pos.y < b.pos.y + b.dim.h
end


function Gui:init()
    self.elements = Conta()
    self.elements_lookup = {}
    self.mouse = elements.mouse(nil, nil, {gui=self})
end


function Gui:clear()
    self.elements = Conta()
    self.elements_lookup = {}
end


function Gui:add(name, x, y, data)
    local data = data or {}
    local element = elements[name](x, y, data)
    local lookup_name = element.name or ("%s_%d"):format(string.lower(name), #self.elements:get(name)+1)
    self.elements_lookup[lookup_name] = element
    return self.elements:add(element)
end


function Gui:get(element)
    local _type = type(element)
    if _type == "string" then return self.elements_lookup[element]
    elseif _type == "table" then return self.elements:get(element)
    else error(("Unsupported element type: %s"):format(_type)) end
end


function Gui:select(element)
    if self.selectedElement and self.selectedElement == element then return end
    if self.selectedElement then self:deselect(self.selectedElement) end
    self.selectedElement = element
    element:onSelect()
end


function Gui:deselect()
    self.selectedElement = nil
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
            mouse.hoverTimer = 0
            mouse.child = nil
        end
    end)
end


function Gui:draw()
    self.elements:draw()
    self.mouse:draw()
end


function Gui:keypressed(...)
    if self.selectedElement then self.selectedElement:keypressed(...) end
end


function Gui:keyreleased(...)
    if self.selectedElement then self.selectedElement:keyreleased(...) end
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


function Gui:textinput(...)
    if self.selectedElement then self.selectedElement:onTextInput(...) end
end

return Gui
