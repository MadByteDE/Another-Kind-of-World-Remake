-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Tile  = require("objects.tile")
local Scene = require("scenes.scene")
local Editor = Scene:extend("editor")


local function addPanelButtons(self)
    -- Clear button
    local button = {}
    button.tooltip  = {text="Undo unsaved changes"}
    button.parent   = self.panel
    button.image    = Game.assets.gui.button.clear
    button.action   = function(element, button)
        if button == 1 then
            Game:transition(function()
                Game:switchScene("editor", Game.level.id)
            end, .5)
        end
    end
    Game.gui:add("button", 0, self.panel.height+1, button)
    -- Save button
    button.tooltip = {text="Save the current level"}
    button.parent = self.panel
    button.image = Game.assets.gui.button.save
    button.action = function(element, button)
        if button == 1 then
            Game.level.id = self.titlebox.text
            Game.level:save(Game.level.id)
            print("Successfully saved level")
        end
    end
    Game.gui:add("button", button.image:getWidth(), self.panel.height+1, button)
    -- Play button
    button.tooltip = {text="play the current level"}
    button.parent = self.panel
    button.image = Game.assets.gui.button.play
    button.action = function(element, button)
        if button == 1 then
            Game:transition(function()
                Game:switchScene("ingame", Game.level:getSaveData(), true)
            end, 1)
        end
    end
    Game.gui:add("button", button.image:getWidth()*2, self.panel.height+1, button)
end


function Editor:init(level)
    self.name = "editor"
    -- Init level
    Game.level:load(id or Game.level.id)
    -- Pre-selected tile when entering editor mode
    self.current_tile = Game.assets.data.tiles[2]  -- wall
    -- Add title box
    local data = {text=Game.level.id, width=72, height=8}
    self.titlebox = Game.gui:add("textbox", Game.width/2, 8, data)
    self.titlebox:center()
    -- Add tile panel
    self.panel = Game.gui:add("tilepanel", 20, (Game.height/2)-8)
    self.panel:center()
    self.panel:addTiles()
    addPanelButtons(self)
end


function Editor:leave()
    if self.panel then self.panel:destroy() end
    if self.titlebox then self.titlebox:destroy() end
end


function Editor:logic(dt)
    -- Place tiles
    if Game.gui.hovered_obj then return end
    if love.mouse.isDown(1) then
        local mx, my = Game:getMousePosition()
        local tx, ty = Game.level:toTileCoords(mx, my)
        local x, y = Game.level:toScreenCoords(tx, ty)
        Game.level:setTile(tx, ty, Tile(x, y, self.current_tile))
    end
end


function Editor:render()
    -- Draw tile preview
    local mx, my = Game:getMousePosition()
    local tx, ty = Game.level:toTileCoords(mx, my)
    local x, y = Game.level:toScreenCoords(tx, ty)
    love.graphics.setColor(1, 1, 1, .3)
    local sprite = Game.assets.tile[self.current_tile.name]
    if self.current_tile then love.graphics.draw(sprite, x, y) end
    -- Draw usage info
    Game:print("TAB - Switch to game", 1, 10, {1, 1, 1, .1})
    Game:print("LMB/RMB - Place/Pick tile", 1, 20, {1, 1, 1, .1})
    Game:print("Space - Play level", 1, 30, {1, 1, 1, .1})
end


function Editor:keypressed(key)
    -- Quit
    if key == "escape" then
        Game:transition(function() love.event.quit() end, 3)
    -- Switch to play mode
    elseif key == "tab" then
        Game:transition(function() Game:switchScene("ingame") end, 1.5)
    -- Save & test editor level
    elseif key == "space" then
        Game:transition(function()
            Game.level:save(self.titlebox.text)
            Game:switchScene("ingame", Game.level.id, true)
        end, 1)
    end
end


function Editor:mousepressed(x, y, button)
    local tx, ty = Game.level:toTileCoords(Game:getMousePosition())
    if button == 2 then
        -- Get tile
        local tile = Game.level:getTile(tx, ty)
        if tile then self.current_tile = Game.assets.data.tiles[tile.id] end
    end
end


function Editor:mousereleased(x, y, button)end
function Editor:wheelmoved(x, y)end


return Editor
