-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Scene = require("scenes.scene")
local Tile  = require("objects.tile")
local Editor = Scene:extend()


function Editor:init(level_id)
    self.name = "Editor"
    -- Pre-selected tile when entering editor mode
    self.current_tile = Game.assets.data.tiles[2]  -- wall
    Game.level:load(level_id or Game.level.id)
    -- Add tile panel
    self.panel = Game.gui:add("tilepanel", 220, 50)
    self.panel:createButtons()
    local data = {
        text=Game.level.id, width=72, height=8,
        action=function(textbox)
            if textbox.text ~= "" then
                self.level_id = textbox.text
            end
        end,}
    -- Add text box
    self.titlebox = Game.gui:add("textbox", Game.width/2-36, 2, data)
end


function Editor:leave()
    if self.panel then self.panel:destroy() end
    if self.titlebox then self.titlebox:destroy() end
end


function Editor:logic(dt)
    Game.level:update(dt)
    -- Place tile
    local tx, ty = Game.level:toTileCoords(Game.gui.mouse.x, Game.gui.mouse.y)
    local x, y = Game.level:toScreenCoords(tx, ty)
    if Game.gui.mouse.button == 1 then
        Game.level:setTile(tx, ty, Tile(x, y, self.current_tile))
    -- Get tile
    elseif Game.gui.mouse.button == 2 then
        local tile = Game.level:getTile(tx, ty)
        if tile then self.current_tile = Game.assets.data.tiles[tile.id] end
    end
end


function Editor:render()
    Game.level:draw()
    -- Draw tile preview
    local tx, ty = Game.level:toTileCoords(Game.gui.mouse.x, Game.gui.mouse.y)
    local x, y = Game.level:toScreenCoords(tx, ty)
    love.graphics.setColor(1, 1, 1, .3)
    local sprite = Game.assets.tile[self.current_tile.name]
    if self.current_tile then love.graphics.draw(sprite, x, y) end
    -- Draw usage info
    Game:print("TAB - Switch to game", 5, 5, {1, 1, 1, .075})
    Game:print("LMB/RMB - Place/Pick tile", 5, 15, {1, 1, 1, .075})
    Game:print("Space - Play level", 5, 25, {1, 1, 1, .075})
end


function Editor:keypressed(key)
    Game.gui:keypressed(key)
    -- Quit
    if key == "escape" then
        Game:transition(function() love.event.quit() end, 3)
    -- Switch to play mode
    elseif key == "tab" then
        Game:transition(function() Game:switchScene("Ingame") end, 1.5)
    -- Save & test editor level
    elseif key == "space" then
        Game:transition(function()
            Game.level:save(self.level_id)
            Game:switchScene("Ingame", Game.level.id, true)
        end, 1)
    end
end


return Editor
