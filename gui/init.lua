-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Class = require("lib.30log")
local Gui = Class("gui")

local Conta = require("lib.conta")

local elements  = {
    button     = require("gui.button"),
    textbox    = require("gui.textbox"),
    tilepanel  = require("gui.tilepanel")
}


function Gui:init()
    self.elements = Conta()
    self.elements_lookup = {}
    self.hovered_obj = nil
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


function Gui:getByParent(parent)
    local elements = {}
    self.elements:iterate(function(key, element)
        if element.parent == parent then
            elements[#elements+1] = element
        end
    end)
    return elements
end


function Gui:update(dt)
    self.elements:update(dt)
end


function Gui:draw()
    self.elements:draw()
end


function Gui:keypressed(...)
    if self.hovered_obj then self.hovered_obj:keypressed(...) end
end


function Gui:keyreleased(...)
    if self.hovered_obj then self.hovered_obj:keyreleased(...) end
end


function Gui:mousemoved(x, y)
    local mx, my = Game:getMousePosition()
    local mouse = {x=mx, y=my, width=1, height=1}
    self.elements:iterate(function(k, other)
        if not other.collide then return end
        local col = rectCollision(mouse, other)
        if col then
            if self.hovered_obj == other.parent or not self.hovered_obj then
                self.hovered_obj = other
                self.hovered_obj:onEnter(mouse)
            end
        elseif not col and other == self.hovered_obj then
            self.hovered_obj:onExit(mouse)
            self.hovered_obj = nil
        end
    end)
end


function Gui:mousepressed(x, y, button)
    if self.hovered_obj then
        local mx, my = Game:getMousePosition()
        self.hovered_obj:onClick(button, mx, my)
    end
end


function Gui:mousereleased(x, y, button)
    if self.hovered_obj then
        local mx, my = Game:getMousePosition()
        self.hovered_obj:onRelease(button, mx, my)
    end
end


function Gui:wheelmoved(x, y)
    if self.hovered_obj then self.hovered_obj:onScroll(x, y)
    else self.scroll = {x=x, y=y} end
end


function Gui:textinput(...)
    if self.hovered_obj then self.hovered_obj:onTextInput(...) end
end


return Gui
