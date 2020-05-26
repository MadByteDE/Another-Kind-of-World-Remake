
local World = Class()
local tw    = Assets.tilesize


local function compare(a, b)
  return a[1] == b[1] and a[2] == b[2] and a[3] == b[3]
end


function World:init(id)
  self.id = id or self.id
  local path = lf.getAppdataDirectory().."/levels/"
  if not lf.getInfo(path) then lf.createDirectory("levels") end
  if type(self.id) == "number" then
    self.tileImage = li.newImageData("assets/levels/".."lvl"..self.id.."col.png")
    self.overlayImage = lg.newImage("assets/levels/".."lvl"..self.id.."over.png")
  elseif type(self.id) == "string" then
    self.tileImage = li.newImageData("/levels/"..id..".png")
  end
  -- init canvas & data containers
  self.canvas   = lg.newCanvas(Screen.width, Screen.height)
  self.tiles    = {}
  self.objects  = Conta()
  self.animatedTiles = Conta()
  self.collisionWorld = Bump.newWorld(24)

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
  self:renderCanvas()
end


function World:save(name)
  local imageData = love.image.newImageData(Screen.width/tw, Screen.height/tw)
  for y = 1, Screen.height/tw do
    for x = 1, Screen.width/tw do
      local pixelColor = self.tiles[y][x].pixelColor
      imageData:setPixel(x-1, y-1, unpack(pixelColor))
    end
  end
  imageData:encode("png", "/levels/"..name..".png")
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
