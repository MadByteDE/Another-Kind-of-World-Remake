-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Bump  = require("lib.bump")
local Conta = require("lib.conta")
local Tile  = require("objects.tile")
local Class = require("lib.30log")
local Level = Class("Level")


-- Fill a table with tile id's instead of tile objects
local function generateTileData(self)
    local tiledata = {}
    for y = 1, Game.height / self.tilesize do
        tiledata[y] = {}
        for x = 1, Game.width / self.tilesize do
            local tile = self:getTile(x, y)
            for key, data in ipairs(Game.assets.data.tiles) do
                if (tile.name == data.name) then tiledata[y][x] = key end
            end
        end
    end
    return tiledata
end


local function createLevel(self)
    self.tiles = {}
    -- Load in an empty level
    for y = 1, Game.height / self.tilesize do
        self.tiles[y] = {}
        for x = 1, Game.width / self.tilesize do
            local tx, ty = self:toScreenCoords(x, y)
            self.tiles[y][x] = Tile(tx, ty, Game.assets.data.tiles[1]) -- background
        end

    end
    -- Load from existing tile data
    if not self.tiledata then return end
    -- Loop through it's content
    for y = 1, Game.height / self.tilesize do
        for x = 1, Game.width / self.tilesize do
            local id = self.tiledata[y][x]
            local tx, ty = self:toScreenCoords(x, y)
            -- Set each tile based on the given tile id
            for index, tiledata in ipairs(Game.assets.data.tiles) do
                if id == index then
                    tiledata.id = index
                    self:setTile(x, y, Tile(tx, ty, tiledata))
                    -- Tile represents an entity - set background tile and spawn the entity
                    if tiledata.type == "entity" and Game.scene.name == "ingame" then
                        self:setTile(x, y, Tile(tx, ty, Game.assets.data.tiles[1])) -- background
                        self:spawn(tiledata.name, tx, ty, tiledata)
                    end
                end
            end
        end
    end
end


function Level:init(id)
    self.tilesize = self.tilesize or 8
    self.canvas = love.graphics.newCanvas(Game.width, Game.height)
    self.tiles = {}
    self.objects = Conta()
    self.animated_tiles = Conta()
    self.collision_world = Bump.newWorld(24)
    self.id = id or self.id or 99
    createLevel(self)
    self:renderCanvas()
end


function Level:load(id)
    local id = tostring(id) or ""
    local paths = {
        "/level/",          -- appdata directory
        "assets/level/"     -- game directory
    }
    self.level_path = nil
    self.overlay = nil
    -- loop over each path
    for k,v in ipairs(paths) do
        if not self.level_path then
            local path = (v .. id .. ".akwlvl")
            if love.filesystem.getInfo(path) then self.level_path = path end
        end
        if not self.overlay then
            local path = (v .. id .. "over.png")
            if love.filesystem.getInfo(path) then self.overlay = love.graphics.newImage(path) end
        end
    end
    -- Found level file -> Initialize
    if self.level_path then
        for k,v in pairs(love.filesystem.load(self.level_path)()) do self[k] = v end
        self:init()
    end
end


function Level:save(id)
    -- Replace the level id with a new one if provided
    self.id = id or self.id
    -- Create level directory in save directory if not already created
    if not love.filesystem.getInfo("/level/") then
        love.filesystem.createDirectory("/level/")
    end
    -- Set output
    local file_path = love.filesystem.getSaveDirectory() .. "/level/" .. self.id .. ".akwlvl"
    local file_handle
    local serialized_data = ""
    -- Get save data and write it to the file
    local savedata = self:getSaveData()
    serialized_data = serialized_data .. "return {\n"
    serialized_data = serialized_data .. "\tid = '".. self.id .."',\n"
    serialized_data = serialized_data .. "\ttilesize = ".. savedata.tilesize ..",\n"
    serialized_data = serialized_data .. "\ttiledata = {\n"
    for y=1, #savedata.tiledata do
        serialized_data = serialized_data .. "\t\t{"
        for x=1, #savedata.tiledata[y] do
            serialized_data = serialized_data .. savedata.tiledata[y][x] .. ","
        end
        serialized_data = serialized_data:sub(1, -1)
        serialized_data = serialized_data .. "},\n"
    end
    serialized_data = serialized_data .. "\t},\n"
    serialized_data = serialized_data .. "}"
    -- Save file
    file_handle = io.open(file_path, "w+")
    if file_handle then
        file_handle:write(serialized_data)
        file_handle:close()
    end
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
        self:renderCanvas()
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


function Level:iterateTiles(f)
    for y = 1, Game.height / self.tilesize do
        for x = 1, Game.width / self.tilesize do
            f(self.tiles[y][x], x, y)
        end
    end
end


function Level:renderCanvas()
    love.graphics.setCanvas(self.canvas)
    self:iterateTiles(function(tile, x, y) tile:draw() end)
    love.graphics.setCanvas()
end


function Level:spawn(name, x, y, data)
    local entity = Game.assets.data.entities[name](x, y, data)
    return self.objects:add(entity)
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
    if self.overlay and Game.scene.name == "ingame" then
        love.graphics.draw(self.overlay)
    end
end

return Level
