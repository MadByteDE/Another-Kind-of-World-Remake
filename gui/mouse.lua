-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Element = require("gui.element")
local Mouse = Class()
Mouse:include(Element)


function Mouse:init(x, y, t)
    love.mouse.setPosition(x*Game.scale.x, y*Game.scale.y)
    Element.init(self, x, y, t)
    self.type   = "mouse"
    self:setDimensions(1, 1)
    self:newSprite(self.type, Game.assets.gui.cursor)
    self:setSprite(self.type)
    local w, h = self.sprite.image:getDimensions()
    self.offset.x = w/2
    self.offset.y = h/2
    self.hover_timer = 0
    self.tooltip_timeout = 1.5
    self.button = 0
    self.scroll = {x=0, y=0}
end


function Mouse:getPosition()
    local mx, my = love.mouse.getPosition()
    return mx/Game.scale.x, my/Game.scale.y
end


function Mouse:logic(dt)
    self:setPosition(self:getPosition())
    if not love.mouse.isDown(self.button) then self.button = 0 end
    if self.child and self.child.hasTooltip then
        self.hover_timer = self.hover_timer + dt
        if self.hover_timer >= self.tooltip_timeout then
            -- Show Tooltip
        end
    end
end


function Mouse:mousepressed(x, y, button)
    if Game.gui.selected_element and Game.gui.selected_element ~= self.child then
        Game.gui:deselect(Game.gui.selected_element)
    end

    if self.child then
        local x, y = self:getPosition()
        self.child:onClick(button, x, y)
        if self.child.selectable then Game.gui:select(self.child) end
    else
        self.button = button
    end
end


function Mouse:mousereleased(x, y, button)
    if self.child then
        local x, y = self:getPosition()
        self.child:onRelease(button, x, y)
    else
        self.button = button
    end
end


function Mouse:wheelmoved(x, y)
    if self.child then
        self.child:onScroll(x, y)
    else
        self.scroll.x = x
        self.scroll.y = y
    end
end

return Mouse
