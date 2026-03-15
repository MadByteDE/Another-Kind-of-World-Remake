-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Tile = require("objects.tile")
local Level = Class()

local entities = {
    player   = require("objects.player"),
    bug      = require("objects.bug"),
    exit     = require("objects.exit"),
    bomb     = require("objects.bomb"),
    particle = require("objects.particle")
}

----------------------------
-- Local functions --
----------------------------

-- Fill a table with tile id's instead of tile objects
local function generateTileData(self)
    local tileData = {}

    for y = 1, Game.height / self.tileSize do
        tileData[y] = {}
        for x = 1, Game.width / self.tileSize do

            local tile = self:getTile(x, y)
            for assKey, assVal in ipairs(Game.assets.data.tiles) do
                if (tile.name == assVal.name) then
                    tileData[y][x] = assKey
                end
            end

        end
    end

    return tileData
end


local function createLevel(self)
    self.tiles = {}

    -- Load in an empty level
    for y = 1, Game.height / self.tileSize do

        self.tiles[y] = {}

        for x = 1, Game.width / self.tileSize do
            local tx = x * self.tileSize - self.tileSize
            local ty = y * self.tileSize - self.tileSize
            self.tiles[y][x] = Tile(self, tx, ty, Game:getTile("back"))
        end

    end

    -- Load from existing tile data
    if self.tileData then

        -- Loop through it's content
        for y = 1, Game.height / self.tileSize do
            for x = 1, Game.width / self.tileSize do
                local tileId = self.tileData[y][x]
                local tx = x * self.tileSize - self.tileSize
                local ty = y * self.tileSize - self.tileSize

                -- Set each tile based on the given tile id
                for assKey, assVal in ipairs(Game.assets.data.tiles) do
                    if (tileId == assKey) then
                        local tile = Tile(self, tx, ty, assVal)
                        self:setTile(x, y, tile)

                        -- Tile represents an entity - set background tile and spawn the entity
                        if (assVal.type == "entity" and Game.scene.name == "Ingame") then
                            self:setTile(x, y, Tile(self, tx, ty, Game:getTile("back")))
                            self:spawn(assVal.name, tx, ty, assVal)
                        end
                    end
                end
            end
        end
    end
end


----------------------------
-- Constructor --
----------------------------

function Level:init(id)
    -- init levelData data
    self.id = id or self.id or "New level"
    for k,v in pairs(self:load(self.id) or {}) do self[k] = v end
    self.tileSize = self.tileSize or 8

    -- init data containers
    self.canvas = love.graphics.newCanvas(Game.width, Game.height)
    self.objects = Conta()
    self.animatedTiles = Conta()
    self.collisionWorld = Bump.newWorld(24)

    -- Create level from tileData & pre-render it to a canvas
    createLevel(self)
    self:renderCanvas()
end


----------------------------
-- Load / Save --
----------------------------

function Level:load(id)
    local id = tostring(id) or ""
    local paths = {
        "/level/",          -- appdata directory
        "assets/level/", } -- game directory

    self.levelPath = nil
    self.overlay = nil

    -- loop over each path
    for k,v in ipairs(paths) do
        if not self.levelPath then
            local path = (v .. id .. ".akwlvl")
            if love.filesystem.getInfo(path) then self.levelPath = path end
        end
        if not self.overlay then
            local path = (v .. id .. "over.png")
            print(path)
            if love.filesystem.getInfo(path) then self.overlay = love.graphics.newImage(path) end
        end
    end

    -- Yey, file exists! Return it's content
    if self.levelPath then
        return love.filesystem.load(self.levelPath)()
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
    local screenFilePath = love.filesystem.getSaveDirectory() .. "/level/" .. self.id .. ".akwlvl"
    local screenFileHandle
    local screenFileData = ""

    -- Get save data and write it to the file
    local saveData = self:getSaveData()
    screenFileData = screenFileData .. "return {\n"
    screenFileData = screenFileData .. "\tid = '".. self.id .."',\n"
    screenFileData = screenFileData .. "\ttileSize = ".. saveData.tileSize ..",\n"
    screenFileData = screenFileData .. "\ttileData = {\n"

    for y=1, #saveData.tileData do
        screenFileData = screenFileData .. "\t\t{"
        for x=1, #saveData.tileData[y] do
            screenFileData = screenFileData .. saveData.tileData[y][x] .. ","
        end
        screenFileData = screenFileData:sub(1, -1)
        screenFileData = screenFileData .. "},\n"
    end

    screenFileData = screenFileData .. "\t},\n"
    screenFileData = screenFileData .. "}"

    -- Save file
    screenFileHandle = io.open(screenFilePath, "w+")
    if screenFileHandle then
        screenFileHandle:write(screenFileData)
        screenFileHandle:close()
    end
end


function Level:getSaveData()
    local tileData = generateTileData(self)
    return {
        id        = self.id,
        tileSize  = self.tileSize,
        tileData  = tileData, }
end


----------------------------
-- Tile manipulation --
----------------------------

function Level:setTile(x, y, tile)
    if self.tiles[y] then
        local currentTile = self.tiles[y][x]
        if currentTile == tile then return end

        if (currentTile.type == "animatedTile") then
            self.animatedTiles:remove(currentTile)
        end

        currentTile:removeCollider()
        currentTile = tile

        if (currentTile.type == "animatedTile") then
            self.animatedTiles:add(currentTile)
        end

        self.tiles[y][x] = currentTile
        self:renderCanvas()
    end
end


function Level:getTile(x, y)
    return self.tiles[y][x]
end


function Level:iterateTiles(f)
    for y = 1, Game.height / self.tileSize do
        for x = 1, Game.width / self.tileSize do
            f(self.tiles[y][x], x, y)
        end
    end
end


function Level:renderCanvas()
    love.graphics.setCanvas(self.canvas)
    self:iterateTiles(function(tile, x, y) tile:draw() end)
    love.graphics.setCanvas()
end


----------------------------
-- Object manipulation --
----------------------------

function Level:spawn(type, x, y, data)
    return self.objects:add(entities[type](self, x, y, data))
end


function Level:getObject(val)
    return self.objects:get(val)
end


----------------------------
-- Main callbacks --
----------------------------

function Level:update(dt)
    self.animatedTiles:update(dt)
    self.objects:update(dt)
end


function Level:draw()
    love.graphics.draw(self.canvas)
    self.animatedTiles:draw()
    self.objects:draw()
    if self.overlay and Game.scene.name == "Ingame" then
        love.graphics.draw(self.overlay)
    end
end

return Level
