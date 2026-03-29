-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Element = require("gui.element")
local Button = Element:extend("Button")


function Button:init(x, y, t)
    Element.init(self, x, y, t)
    self.type = "button"
    self.rgba = {.8, .8, .8, .75}
    self.hovered = false
    self.visible = true
    if self.image then
        self:newSprite(self.type, self.image)
        self:setSprite(self.type)
        local w, h = self.sprite.image:getDimensions()
        self:setDimensions(w, h)
    end
    self.action = self.action or function() end
end


function Button:onEnter(mouse)
    Element.onEnter(self, mouse)
    self.rgba = {1, 1, 1, 1}
end


function Button:onExit(mouse)
    Element.onExit(self, mouse)
    self.rgba = {.8, .8, .8, .75}
end


function Button:onClick(button, x, y)
    Element.onClick(self, button, x, y)
    self.rgba = {.45, .45, .45, 1}
end


function Button:onRelease(button, x, y)
    Element.onRelease(self, button, x, y)
    self.rgba = {1, 1, 1, 1}
    self.action(self, button)
end

return Button
