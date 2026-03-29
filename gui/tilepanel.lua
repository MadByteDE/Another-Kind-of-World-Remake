-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Element = require("gui.element")
local Tilepanel = Element:extend()


function Tilepanel:init(x, y, t)
    Element.init(self, x, y, t)
    self.type       = "tilepanel"
    self.draggable  = true
    self.rgba       = {1, 1, 1, .7}
    self:newSprite(self.type, Game.assets.gui.tilepanel)
    self:setSprite(self.type)
    local w, h = self.sprite.image:getDimensions()
    self:setDimensions(w, h)
    self.buttons = {}
end


function Tilepanel:createButtons()
    local x, y, w, h = self.x, self.y, self.width, self.height
    -- Buttons for individual tiles
    self.buttons = {}
    local tw = Game.level.tilesize
    for index, tiledata in ipairs(Game.assets.data.tiles) do
        local rowsize = 3
        local spacing = 1
        local row     = math.floor((index-1)/rowsize)
        local column  = (index-1)%rowsize
        local x       = 2+column*tw+spacing*column
        local y       = 4+row*tw+spacing*row
        -- Clear button
        local button = {image=Game.assets.tile[tiledata.name], parent=self}
        button.width = tw
        button.height = tw
        button.tile = tiledata
        button.tooltip = {text=tiledata.name}
        button.action = function(b, pressed)
            if pressed == 1 then Game.scene.current_tile = button.tile end
        end
        table.insert(self.buttons, Game.gui:add("button", x, y, button))
    end
    -- Clear button
    local button = {image = Game.assets.gui.button.clear, parent = self}
    button.action = function(b, pressed)
        if pressed == 1 then
            Game:transition(function() Game.scene:init() end, .5)
        end
    end
    table.insert(self.buttons, Game.gui:add("button", 0, self.height+1, button))
    -- Save button
    local button = {image = Game.assets.gui.button.save, parent = self}
    button.action = function(b, pressed)
        if pressed == 1 then
            Game.level:save(Game.scene.level_id)
            print("Successfully saved level")
        end
    end
    table.insert(self.buttons, Game.gui:add("button", 11, self.height+1, button))
    -- Play button
    local button = {image = Game.assets.gui.button.play, parent = self}
    button.action = function(b, pressed)
        if pressed == 1 then
            Game:transition(function()
                Game.level:save()
                Game:switchScene("Ingame", Game.level.id, true)
            end)
        end
    end
    table.insert(self.buttons, Game.gui:add("button", 22, self.height+1, button))
end


function Tilepanel:destroy()
    for k,v in ipairs(self.buttons) do v:destroy() end
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

return Tilepanel
