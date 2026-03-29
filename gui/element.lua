-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Object = require("objects.object")
local Element = Object:extend("Element")


function Element:init(x, y, t)
    Object.init(self, x, y, t)
    self.type       = "element"
    self.text       = self.text or self.type
    self.collide    = self.collide or true
    self.draggable  = self.draggable or false
    self.selectable = self.selectable or false
    self.hovered    = false
    self.dragged    = false
    self.centered   = false
    self.diff       = {x=0, y=0}
    self.tooltip    = self.tooltip or {}
    self.tooltip.text = self.tooltip.text or nil
    self.tooltip.delay = self.tooltip.delay or 2
    self.tooltip.timer = 0
    self.tooltip.show = false
end


function Element:setPosition(x, y)
    self.x = x; self.y = y
    if self.parent then
        self.x = self.x + self.parent.x
        self.y = self.y + self.parent.y
    end
end


function Element:center(x, y)
    if self.centered then return end
    local x = (x or self.x) - self.width/2
    local y = (y or self.y) - self.height/2
    self.x = x; self.y = y
    self.centered = true
end


function Element:logic(dt)
    -- Dragging
    local mx, my = Game:getMousePosition()
    if self.parent then
        if self.parent.dragged and not self.dragged then
            self.diff = { x = mx-self.x, y = my-self.y }
            self.dragged = true
        elseif not self.parent.dragged and self.dragged then
            self.diff = { x = 0, y = 0 }
            self.dragged = false
        end
    end
    if self.dragged then
        self.x = mx - self.diff.x
        self.y = my - self.diff.y
    end
    -- Tooltip on hover
    if self.hovered then
        if self.tooltip.text then
            if self.tooltip.timer > 0 then
                self.tooltip.timer = self.tooltip.timer - dt
            end
            if self.tooltip.timer <= 0 then
                self.tooltip.show = true
                self.tooltip.timer = 0
            end
        end
    end
end


function Element:drawTooltip(x, y)
    if not self.tooltip.show then return end
    local font = love.graphics.getFont()
    local mx, my = Game:getMousePosition()
    local x, y = mx, my - 16
    local w, h = font:getWidth(self.tooltip.text), font:getHeight()
    love.graphics.setColor(0, 0, 0, .5)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(self.tooltip.text, x, y)
end


function Element:render()
    if not self.visible then return end
    local mx, my = Game:getMousePosition()
    self:drawTooltip(mx, my - 16)
end


function Element:onEnter(mouse)
    self.hovered = true
    if self.tooltip.timer <= 0 then self.tooltip.timer = self.tooltip.delay end
end


function Element:onExit(mouse)
    self.hovered = false
    self.tooltip.show = false
    self.tooltip.timer = self.tooltip.delay
end


function Element:onClick(button, x, y)
    if self.draggable and button == 1 then
        self.dragged = true
        self.diff = {x=x-self.x, y=y-self.y}
    end
end


function Element:onRelease(button, x, y)
  if self.dragged then
    self.dragged = false
    self.diff = {x=0, y=0}
  end
end


function Element:onScroll(x, y) end


function Element:keypressed()end
function Element:keyreleased()end

return Element