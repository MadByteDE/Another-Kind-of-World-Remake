-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Element = require("gui.element")
local Tilepanel = Class()
Tilepanel:include(Element)


function Tilepanel:init(x, y, t)
    Element.init(self, x, y, t)
    self.type       = "tilepanel"
    self.draggable  = true
    self.rgba       = {1, 1, 1, .7}
    self:newSprite(self.type, Game.assets.gui.tilepanel)
    self:setSprite(self.type)
    local w, h = self.sprite.image:getDimensions()
    self.dim = {w=w, h=h}
    self.buttons = {}
end


function Tilepanel:createButtons()
  local x, y, w, h = self.pos.x, self.pos.y, self.dim.w, self.dim.h
    -- Buttons for individual tiles
    self.buttons = {}
    local tw = 8
    local index = 0
    for name, tiledata in pairs(Game.assets.data.tiles) do
        index = index + 1
        local rowsize = 3
        local spacing = 1
        local row     = math.floor((index-1)/rowsize)
        local column  = (index-1)%rowsize
        local x       = self.pos.x+2+column*tw+spacing*column
        local y       = self.pos.y+4+row*tw+spacing*row
        -- Clear button
        local button = {image = Game.assets.tile[name], parent = self}
        button.dim = {w=tw, h=tw}
        button.tile = tiledata
        button.action = function(button, pressed)
            if pressed == 1 then Game.scene.current_tile = button.tile end
        end
        table.insert(self.buttons, Game.gui:add("button", x, y, button))
    end
    -- Clear button
    local button = {image = Game.assets.gui.button.clear, parent = self}
    button.action = function(button, pressed)
        if pressed == 1 then
            Game:transition(function() Game.scene:init() end, .5)
        end
    end
    table.insert(self.buttons, Game.gui:add("button", x, y+h+1, button))
    -- Save button
    local button = {image = Game.assets.gui.button.save, parent = self}
    button.action = function(button, pressed)
        if pressed == 1 then
            Game.level:save(Game.scene.level_id)
            print("Successfully saved level")
        end
    end
    table.insert(self.buttons, Game.gui:add("button", x+11, y+h+1, button))
    -- Play button
    local button = {image = Game.assets.gui.button.play, parent = self}
    button.action = function(button, pressed)
        if pressed == 1 then
            Game:transition(function()
                Game.level:save()
                Game:switchScene("Ingame", Game.level.id, true)
            end)
        end
    end
    table.insert(self.buttons, Game.gui:add("button", x+22, y+h+1, button))
end


function Tilepanel:destroy()
    for k,v in ipairs(self.buttons) do
        v:destroy()
    end
    Element.destroy(self)
end


function Tilepanel:onEnter(mouse)
    Element.onEnter(self, mouse)
    self.rgba = {1, 1, 1, .9}
end


function Tilepanel:onExit(mouse)
    Element.onExit(self, mouse)
    self.rgba = {1, 1, 1, .7}
end


function Tilepanel:onClick(button, x, y)
    Element.onClick(self, button, x, y)
end


function Tilepanel:onRelease(button, x, y)
    Element.onRelease(self, button, x, y)
end


function Tilepanel:onScroll(x, y)
end


function Tilepanel:logic(dt)
end


function Tilepanel:render()
end

return Tilepanel
