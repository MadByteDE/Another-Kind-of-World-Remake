
local World = Class()
local tw    = Assets.tilesize


local function compare(a, b)
  return a[1] == b[1] and a[2] == b[2] and a[3] == b[3]
end


function World:init(id)
  self.id = id or self.id
  self.updatedSaveVersionAvailable = false
  local path = lf.getAppdataDirectory().."/levels/"

  -- Create levels directory if this is the first time touching it
  if not lf.getInfo(path) then lf.createDirectory("levels") end

  -- Check if level is loaded with number(pre defined) or string(from editor)
  if type(self.id) == "number" then

    self.tileImage = li.newImageData("assets/levels/".."lvl"..self.id.."col.png")
    self.overlayImage = lg.newImage("assets/levels/".."lvl"..self.id.."over.png")

  elseif type(self.id) == "string" then
    self.tileImage = li.newImageData("/levels/"..id..".png")

    -- Check to see if there is a level saved with new file-type available
    self.levelPath = (love.filesystem.getSaveDirectory() .. "/levels/" .. id .. ".akwlvl")
    if (io.open(self.levelPath, "r")) then
      self.updatedSaveVersionAvailable = true
    end

  end

  -- init canvas & data containers
  self.canvas   = lg.newCanvas(Screen.width, Screen.height)
  self.tiles    = {}
  self.objects  = Conta()
  self.animatedTiles = Conta()
  self.collisionWorld = Bump.newWorld(24)

  -- If new file-type isn't available, do it the old fashioned way
  if not self.updatedSaveVersionAvailable then

    -- Generate tiles
    for y = 1, Screen.height/tw do
      self.tiles[y] = {}
      for x = 1, Screen.width/tw do
        local tx = x*tw-tw
        local ty = y*tw-tw
        -- Generate from imageData
        if self.tileImage then
          local pixelColor = {self.tileImage:getPixel(x-1, y-1)}
          for k,v in pairs(Assets.tiles) do
            if compare(pixelColor, v.pixelColor) then
              local tile = Tile(self, tx, ty, v)
              if v.type == "animatedTile" then
                self.animatedTiles:add(tile)
              elseif v.type == "entity" and CurrentScene == Game then
                tile = Tile(self, tx, ty, Assets.getTile("back"))
                self:spawn(v.name, tx, ty, v)
              end
              self.tiles[y][x] = tile
            end
          end
        else
          -- Else generate blank / background tiles
          self.tiles[y][x] = Tile(self, tx, ty, Assets.getTile("back"))
        end
      end
    end

  -- Seems like new filetype is available!
  else

    -- First, let's load in an empty level
    for y = 1, Screen.height/tw do
      self.tiles[y] = {}
      for x = 1, Screen.width/tw do
        local tx = x*tw-tw
        local ty = y*tw-tw
        self.tiles[y][x] = Tile(self, tx, ty, Assets.getTile("back"))
      end
    end

    -- Now, let's see if we can read the generated file... it should load into levelData
    print("Loading new filetype!")
    dofile(self.levelPath)
    for loadKey, loadVal in pairs(levelData) do
      for assKey, assVal in pairs(Assets.tiles) do -- yea, I named them that because it was fun
        local tx = loadVal.pos.x*tw-tw
        local ty = loadVal.pos.y*tw-tw
        if (loadVal.name == assVal.name) then
          local tile = Tile(self, tx, ty, assVal)
          if (assVal.type == "animatedTile") then
            self.animatedTiles:add(tile)
          elseif (assVal.type == "entity" and CurrentScene == Game) then
            tile = Tile(self, tx, ty, Assets.getTile("back"))
            self:spawn(assVal.name, tx, ty, assVal)
          end
          self.tiles[loadVal.pos.y][loadVal.pos.x] = tile
        end
      end      
    end

  end

  self:renderCanvas()
end


function World:save(name)
  -- Old save method
  local imageData = love.image.newImageData(Screen.width/tw, Screen.height/tw)
  for y = 1, Screen.height/tw do
    for x = 1, Screen.width/tw do
      local pixelColor = self.tiles[y][x].pixelColor
      imageData:setPixel(x-1, y-1, unpack(pixelColor))
    end
  end
  imageData:encode("png", "/levels/"..name..".png")

  -- New save method
  -- Set output
  local screenFilePath = (love.filesystem.getSaveDirectory() .. "/levels/" .. name .. ".akwlvl")
  local screenFileHandle
  local screenFileData = ""

  -- Init this layer
  screenFileData = screenFileData .. "levelData = {\n"

  -- Loop over tiles in this world
  for y = 1, Screen.height/tw do

    for x = 1, Screen.width/tw do

        -- Create tile element
        screenFileData = screenFileData .. "\t{\n"
        screenFileData = screenFileData .. "\t\tpos = {\n"
        screenFileData = screenFileData .. "\t\t\tx = " .. x .. ",\n"
        screenFileData = screenFileData .. "\t\t\ty = " .. y .. "\n"
        screenFileData = screenFileData .. "\t\t},\n"
        screenFileData = screenFileData .. "\t\tname = \"" .. self.tiles[y][x].name .. "\",\n"
        screenFileData = screenFileData .. "\t\ttype = \"" .. self.tiles[y][x].type .. "\",\n"
        screenFileData = screenFileData .. "\t\tcollides = " .. (self.tiles[y][x].collides and "true" or "false") .. ",\n"
        screenFileData = screenFileData .. "\t\tsolid = " .. (self.tiles[y][x].solid and "true" or "false") .. "\n"
        screenFileData = screenFileData .. "\t},\n"

    end

  end

  -- Close this layer
  screenFileData = screenFileData .. "}\n"

  -- Save file
  screenFileHandle = io.open(screenFilePath, "w+")
  screenFileHandle:write(screenFileData)
  screenFileHandle:close()

end


function World:iterateTiles(f)
  for y = 1, Screen.height/tw do
    for x = 1, Screen.width/tw do
      f(self.tiles[y][x], x, y)
    end
  end
end


function World:spawn(type, x, y, v)
  return self.objects:add(Entities[type](self, x, y, v))
end


function World:getObject(val)
  return self.objects:get(val)
end


function World:setTile(x, y, v)
  if self.tiles[y] then
    local tile = self.tiles[y][x]
    if tile.type == "animatedTile" then self.animatedTiles:remove(tile) end
    tile:removeCollider()
    tile = v
    if tile.type == "animatedTile" then self.animatedTiles:add(tile) end
    self.tiles[y][x] = tile
  else error("There's no tile at X:"..x.." Y:"..y) end
end


function World:getTile(x, y)
  return self.tiles[y][x]
end


function World:renderCanvas()
  lg.setCanvas(self.canvas)
  self:iterateTiles(function(tile, x, y) tile:draw() end)
  lg.setCanvas()
end


function World:update(dt)
  self.animatedTiles:update(dt)
  self.objects:update(dt)
end


function World:draw()
  lg.draw(self.canvas)
  self.animatedTiles:draw()
  self.objects:draw()
  if self.overlayImage then lg.draw(self.overlayImage) end
end

return World
