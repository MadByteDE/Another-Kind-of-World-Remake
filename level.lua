-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Bump  = require("lib.bump")
local Conta = require("lib.conta")
local Tile  = require("objects.tile")
local Class = require("lib.30log")
local Level = Class("Level")


local function generateTileData(self)
    -- Fill a table with tile id's instead of tile objects
    local tiledata = {}
    for y = 1, Game.height/self.tilesize do
        tiledata[y] = {}
        for x = 1, Game.width/self.tilesize do
            local tile = self:getTile(x, y)
            for key, data in ipairs(Game.assets.data.tiles) do
                if (tile.name == data.name) then tiledata[y][x] = key end
            end
        end
    end
    return tiledata
end


local function generateEmptyLevel(self)
    self.tiles = {}
    for y = 1, Game.height/self.tilesize do
        self.tiles[y] = {}
        for x = 1, Game.width/self.tilesize do
            local tx, ty = self:toScreenCoords(x, y)
            local tile = Game.assets.data.tiles[1] -- background
            self.tiles[y][x] = Tile(tx, ty, tile)
            self:drawToCanvas(function() self.tiles[y][x]:draw() end)
        end
    end
end


local function createLevel(self)
    -- Loop through the tiledata
    for y = 1, Game.height/self.tilesize do
        for x = 1, Game.width/self.tilesize do
            local id = self.tiledata[y][x]
            local tx, ty = self:toScreenCoords(x, y)
            -- Set each tile based on the given tile id
            for index, tile in ipairs(Game.assets.data.tiles) do
                if id == index then
                    self:setTile(x, y, Tile(tx, ty, tile))
                    -- Tile represents an entity - set background tile and spawn the entity
                    if tile.type == "entity" and Game.scene.name == "ingame" then
                        --[[ HACK: We cannot replace the tile in the tiles table, so we use
                             an extra tile object and draw it on top of the entity tile ]]
                        local overlay_tile = Tile(tx, ty, Game.assets.data.tiles[1])
                        self:drawToCanvas(function() overlay_tile:draw() end)
                        self:spawn(tile.name, tx, ty, tile)
                    end
                end
            end
        end
    end
end


function Level:init(data)
    -- Core
    for k, v in pairs(data or {}) do self[k] = v end
    self.objects = Conta()
    self.animated_tiles = Conta()
    self.collision_world = Bump.newWorld(24)
    self.canvas = self.canvas or love.graphics.newCanvas(Game.width, Game.height)
    -- Init level
    self.id = self.id or "Unnamed"
    self.tilesize = self.tilesize or 8
    self.levelpath = "assets/level/"..self.id..".akwlvl"
    self.overlay = nil
    generateEmptyLevel(self)
    if self.tiledata then createLevel(self) end
    -- Overlay
    local path = getFilePath(self.levelpath)..self.id.."over.png"
    if love.filesystem.getInfo(path) and Game.scene.name ~= "editor" then
        self.overlay = love.graphics.newImage(path)
    end
end


function Level:loadFromFile(path)
    assert(getFileExtension(path) == "akwlvl", "Invalid file extension: "..path)
    assert(love.filesystem.getInfo(path), "Cannot find level file: "..path)
    Log:debug("Level path: %s", path)
    local leveldata = love.filesystem.load(path)()
    -- Load level
    self:init(leveldata)
end


function Level:load(level)
    -- Load level
    local t = type(level)
    if t == "number" or t == "string" then
        self.levelpath = "assets/level/"..level..".akwlvl"
        assert(love.filesystem.getInfo(self.levelpath), "Cannot find level file: "..self.levelpath)
        self:loadFromFile(self.levelpath)
    else
        self:init(level)
    end
end


function Level:save(id)
    -- Replace the level id with a new one if provided
    if id then self.id = id end
    -- Create level directory in save directory if not already created
    love.filesystem.createDirectory(getFilePath(self.levelpath))
    -- Generate id table
    self.tiledata = generateTileData(self)
    -- Serialize level
    local str = "return {\n"
    str = str.."\tid = \""..self.id.."\",\n"
    str = str.."\ttilesize = "..self.tilesize..",\n"
    str = str.."\ttiledata = {\n"
    for y=1, #self.tiledata do
        str = str.."\t\t{"
        for x=1, #self.tiledata[y] do str = str..self.tiledata[y][x].."," end
        str = str:sub(1, -2).."},\n"
    end
    str = str.."\t},\n"
    str = str.."}"
    -- Save to file
    love.filesystem.write(self.levelpath, str)
end


function Level:getSaveData()
    return {id=self.id, tilesize=self.tilesize, tiledata=generateTileData(self)}
end


function Level:setTile(x, y, tile)
    if self.tiles[y] then
        local current_tile = self.tiles[y][x]
        if current_tile == tile then return end
        if current_tile.animdata then self.animated_tiles:remove(current_tile) end
        current_tile:removeCollider()
        current_tile = tile
        if current_tile.animdata then self.animated_tiles:add(current_tile) end
        self.tiles[y][x] = current_tile
        -- Update tile in canvas
        self:drawToCanvas(function() current_tile:draw() end)
    end
end


function Level:getTile(x, y)
    return self.tiles[y][x]
end


function Level:toTileCoords(x, y)
    return math.floor(x/self.tilesize)+1, math.floor(y/self.tilesize)+1
end


function Level:toScreenCoords(x, y)
    return x*self.tilesize-self.tilesize, y*self.tilesize-self.tilesize
end


function Level:drawToCanvas(drawFunction, ...)
    love.graphics.setCanvas(self.canvas)
    drawFunction(...)
    love.graphics.setCanvas()
end


function Level:iterateTiles(f)
    for y = 1, Game.height/self.tilesize do
        for x = 1, Game.width/self.tilesize do
            f(self.tiles[y][x], x, y)
        end
    end
end


function Level:spawn(name, x, y, data)
    return self.objects:add(Game.assets.data.entities[name](x, y, data))
end


function Level:getObject(val)
    return self.objects:get(val)
end


function Level:update(dt)
    self.animated_tiles:update(dt)
    self.objects:update(dt)
end


function Level:draw()
    love.graphics.draw(self.canvas)
    self.animated_tiles:draw()
    self.objects:draw()
    if self.overlay then love.graphics.draw(self.overlay) end
end

return Level
