
local Level = Class()

----------------------------
-- Local functions --
----------------------------

-- Fill a table with tile id's instead of tile objects
local function generateTileData(self)
  local tileData = {}
  for y = 1, Screen.height / self.tileSize do
    tileData[y] = {}
    for x = 1, Screen.width / self.tileSize do
      local tile = self:getTile(x, y)
      for assKey, assVal in ipairs(Assets.tiles) do
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
  for y = 1, Screen.height / self.tileSize do
    self.tiles[y] = {}
    for x = 1, Screen.width / self.tileSize do
      local tx = x * self.tileSize - self.tileSize
      local ty = y * self.tileSize - self.tileSize
      self.tiles[y][x] = Tile(self, tx, ty, Assets.getTile("back"))
    end
  end

  -- Load from existing tile data
  if self.tileData then

    -- Loop through it's content
    for y = 1, Screen.height / self.tileSize do
      for x = 1, Screen.width / self.tileSize do
        local tileId = self.tileData[y][x]
        local tx = x * self.tileSize - self.tileSize
        local ty = y * self.tileSize - self.tileSize

        -- Set each tile based on the given tile id
        for assKey, assVal in ipairs(Assets.tiles) do
          if (tileId == assKey) then
            self:setTile(x, y, Tile(self, tx, ty, assVal))

            -- Tile represents an entity - set background tile and spawn the entity
            if (assVal.type == "entity" and CurrentScene == Game) then
              self:setTile(x, y, Tile(self, tx, ty, Assets.getTile("back")))
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
  for k,v in pairs(self:loadLevelData(id) or {}) do self[k] = v end
  self.id       = self.id or "noname"
  self.tileSize = self.tileSize or 8

  -- init data containers
  self.canvas   = love.graphics.newCanvas(Screen.width, Screen.height)
  self.objects  = Conta()
  self.animatedTiles = Conta()
  self.collisionWorld = Bump.newWorld(24)

  -- Create level from tileData & pre-render it to a canvas
  createLevel(self)
  self:renderCanvas()
end


----------------------------
-- Load / Save --
----------------------------

function Level:loadLevelData(id)
  local id = tostring(id) or ""
  local paths = {
    "assets/levels/", -- working directory
    "levels/", }     -- appdata directory

    print(paths[1])
    print(paths[2])
  -- loop over each path
  for i=1, #paths do
    local levelPath = (paths[i] .. id .. ".akwlvl")
    local overlayPath = (paths[i] .. id .. "over.png")

    -- File found? Set the level path
    if love.filesystem.getInfo(levelPath) then
      self.levelPath = levelPath
    end

    -- look into both paths for an overlay image
    if love.filesystem.getInfo(overlayPath) then
      self.overlay = love.graphics.newImage(overlayPath)
    end
  end

  -- Yey, file exists! Return it's content
  if self.levelPath then
    return love.filesystem.load(self.levelPath)()
  end
end


function Level:saveLevelData(id)
  local id = id or self.id

  -- Create level directory in save directory if not already created
  if not love.filesystem.getInfo("/levels/") then
    love.filesystem.createDirectory("/levels/")
  end

  -- Set output
  local screenFilePath = love.filesystem.getSaveDirectory() .. "/levels/" .. id .. ".akwlvl"
  local screenFileHandle
  local screenFileData = ""

  -- Get save data and write it to the file
  local saveData = self:getSaveData()
  screenFileData = screenFileData .. "return {\n"
  screenFileData = screenFileData .. "\tid = '".. id .."',\n"
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
  screenFileHandle:write(screenFileData)
  screenFileHandle:close()
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

    if (currentTile.type == "animatedTile") then
      self.animatedTiles:remove(currentTile)
    end

    currentTile:removeCollider()
    currentTile = tile

    if (currentTile.type == "animatedTile") then
      self.animatedTiles:add(currentTile)
    end

    self.tiles[y][x] = currentTile
  end
end


function Level:getTile(x, y)
  return self.tiles[y][x]
end


function Level:iterateTiles(f)
  for y = 1, Screen.height / self.tileSize do
    for x = 1, Screen.width / self.tileSize do
      f(self.tiles[y][x], x, y)
    end
  end
end


function Level:renderCanvas()
  love.graphics.setCanvas(self.canvas)
  self:iterateTiles(function(tile, x, y) tile:draw() end)
  if self.overlay and CurrentScene == Game then
    love.graphics.draw(self.overlay)
  end
  love.graphics.setCanvas()
end


----------------------------
-- Object manipulation --
----------------------------

function Level:spawn(type, x, y, v)
  return self.objects:add(Entities[type](self, x, y, v))
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
end

return Level
