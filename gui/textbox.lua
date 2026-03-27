-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Element = require("gui.element")
local utf8 = require("utf8")
local Textbox = Class()
Textbox:include(Element)


function Textbox:init(x, y, t)
    Element.init(self, x, y, t)
    self.type = "Textbox"
    self.text = self.text or ""
    self.action = self.action or function() end
    self.selectable = true
    self.text_color = {1, 1, 1, .75}
    self.rgba = {.05, .05, .05, .5}
    Game.gui:select(self)
    self:setTimeout(4)
end


function Textbox:onEnter(mouse)
    Element.onEnter(self, mouse)
    Game.gui:select(self)
end


function Textbox:onExit(mouse)
    Element.onExit(self, mouse)
    self:setTimeout(10)
end


function Textbox:onSelect()
    Element.onSelect(self)
    self.visible = true
    love.keyboard.setTextInput(true)
end


function Textbox:onDeselect()
    Element.onDeselect(self)
    self:action()
    self.visible = false
    self.rgba = {.05, .05, .05, .5}
    self.text_color = {1, 1, 1, .75}
    love.keyboard.setTextInput(false)
end


function Textbox:onTimeout()
    Game.gui:deselect(self)
end


function Textbox:onClick(Textbox, x, y)
end


function Textbox:onRelease(Textbox, x, y)
end


function Textbox:keypressed(key)
    if key == "backspace" then
        self:setTimeout(0)
        local byteoffset = utf8.offset(self.text, -1)
        if byteoffset then
            self.text = string.sub(self.text, 1, byteoffset-1)
        end
    end
end


function Textbox:onTextInput(text)
    local font = love.graphics.getFont()
    if font:getWidth(self.text) > self.width-5 then return end
    self:setTimeout(0)
    self.text = self.text .. text:gsub('[%p%c%s]', '') -- remove symbols etc.
end


function Textbox:logic(dt)
end


function Textbox:render()
    self:drawRectangle("fill")
    Game:printf(self.text, self.x, self.y-.5, self.width, "center", self.text_color)
end

return Textbox