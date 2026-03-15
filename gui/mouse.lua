-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Element = require("gui.element")
local Mouse = Class()
Mouse:include(Element)


function Mouse:init(x, y, t)
    local mx, my = self:getPosition(x, y)
    Element.init(self, mx, my, t)
    self.type     = "mouse"
    self.dim      = {w=1, h=1}
    self:newSprite(self.type, Game.assets.gui.cursor)
    self:setSprite(self.type)
    local w, h = self.sprite.image:getDimensions()
    self.trans.ox = w/2
    self.trans.oy = h/2
    self.hoverTimer = 0
    self.tooltipTimeout = 1.5
    self.button = 0
    self.scroll = {x=0, y=0}
end


function Mouse:setPosition(x, y)
    love.mouse.setPosition(x*Game.scale.x, y*Game.scale.y)
end


function Mouse:getPosition()
    local mx, my = love.mouse.getPosition()
    return mx/Game.scale.x, my/Game.scale.y
end


function Mouse:logic(dt)
  self.pos.x, self.pos.y = self:getPosition()
    if not love.mouse.isDown(self.button) then self.button = 0 end
    if self.child and self.child.hasTooltip then
        self.hoverTimer = self.hoverTimer + dt
        if self.hoverTimer >= self.tooltipTimeout then
            -- Show Tooltip
        end
    end
end


function Mouse:mousepressed(x, y, button)
    if Game.gui.selectedElement and Game.gui.selectedElement ~= self.child then
        Game.gui:deselect(Game.gui.selectedElement)
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
