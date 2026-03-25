-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Scene = require("scenes.scene")
local Tile  = require("objects.tile")
local Editor  = Class()
Editor:include(Scene)

local tw


function Editor:init(level_id)
    self.name = "Editor"

    -- Pre-selected tile when entering editor mode
    self.current_tile = Game.assets.data.tiles[2]  -- wall

    Game.level:load(level_id or Game.level.id)
    tw = Game.level.tilesize

    -- Add tile panel
    self.panel = Game.gui:add("tilepanel", 220, 50)
    self.panel:createButtons()
    local data = {
        text = Game.level.id,
        dim = {w=72,h=8},
        action = function(textbox)
            if textbox.text ~= "" then
                self.level_id = textbox.text
            end
        end, }
    self.titlebox = Game.gui:add("textbox", Game.width/2-36, 2, data)
end


function Editor:leave()
    if self.panel then self.panel:destroy() end
    if self.titlebox then self.titlebox:destroy() end
end


function Editor:toTileCoords(x, y)
    return math.floor(x/tw)+1, math.floor(y/tw)+1
end


function Editor:toScreenCoords(x, y)
    return x*tw-tw, y*tw-tw
end


function Editor:logic(dt)
    Game.level:update(dt)
    local mouse = Game.gui:getMouse()
    local tx, ty = self:toTileCoords(mouse.pos.x, mouse.pos.y)
    if mouse.button == 1 then
        Game.level:setTile(tx, ty, Tile(tx*tw-tw, ty*tw-tw, self.current_tile))
    elseif mouse.button == 2 then
        local tile = Game.level:getTile(tx, ty)
        if tile then self.current_tile = Game.assets.data.tiles[tile.name] end
    end
end


function Editor:render()
    Game.level:draw()
    local mouse = Game.gui:getMouse()
    local tx, ty = self:toTileCoords(mouse.pos.x, mouse.pos.y)
    love.graphics.setColor(1, 1, 1, .3)
    if self.current_tile then
        love.graphics.draw(Game.assets.tile[self.current_tile.name], tx*tw-tw, ty*tw-tw)
    end
    Game:print("TAB - Switch to game", 5, 5, {1, 1, 1, .075})
    Game:print("LMB/RMB - Place/Pick tile", 5, 15, {1, 1, 1, .075})
    Game:print("Space - Play level", 5, 25, {1, 1, 1, .075})
end


function Editor:keypressed(key)
    Game.gui:keypressed(key)
    if key == "escape" then
        Game:transition(function() love.event.quit() end, 3)
    elseif key == "tab" then
        Game:transition(function()
            Game:switchScene("Ingame")
        end, 1.5)
    elseif key == "space" then
        Game:transition(function()
            Game.level:save(self.level_id)
            Game:switchScene("Ingame", Game.level.id, true)
        end, 1)
    end
end


return Editor
