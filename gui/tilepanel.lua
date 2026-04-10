-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Element = require("gui.element")
local Tilepanel = Element:extend("tilepanel")


function Tilepanel:init(x, y, t)
    Element.init(self, x, y, t)
    self.name       = "tilepanel"
    self.draggable  = true
    self.rgba       = {1, 1, 1, .7}
    self:setSprite(self.name, Game.assets.gui.tilepanel)
    self:setDimensions(self.sprite.image:getDimensions())
end


function Tilepanel:addTiles(tiles)
    -- Tile buttons
    local tw = Game.level.tilesize
    local rows, spacing = 3, 1
    for index, tiledata in ipairs(tiles or Game.assets.data.tiles) do
        local column = (index-1)%rows
        local row = math.floor((index-1)/rows)
        local x = 2+column*tw+spacing*column
        local y = 4+row*tw+spacing*row
        local button = {
            parent=self, width=tw, height=tw,
            image=Game.assets.tile[tiledata.name],
            tooltip={text=tiledata.name},
            tile=tiledata,
            action=function(button, pressed)
                if pressed == 1 then Game.scene.current_tile = button.tile end
            end,
        }
        Game.gui:add("button", x, y, button)
    end
end


function Tilepanel:destroy()
    for k,v in ipairs(Game.gui:getByParent(self)) do v:destroy() end
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
