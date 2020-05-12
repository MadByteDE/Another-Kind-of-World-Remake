
local lg = love.graphics

local function compare(a, b)
  return a[1] == b[1] and a[2] == b[2] and a[3] == b[3]
end

local Screen  = require("source.screen")
local Assets  = require("source.assets")
local Tile    = require("source.tile")
local Player  = require("source.player")
local Bug     = require("source.bug")
local Exit    = require("source.exit")
local Class   = require("source.lib.class")
local Conta   = require("source.lib.conta")
local Bump    = require("source.lib.bump")
local World   = Class()


function World:init(lvl)
  collectgarbage("collect")
  self.level  = lvl or self.level or 0
  local path  = "assets/levels/"

  self.collisionWorld = Bump.newWorld(24)
  self.tileImage      = love.image.newImageData(path.."lvl"..self.level.."col.png")
  self.overlayImage   = lg.newImage(path.."lvl"..self.level.."over.png")

  self.canvas   = lg.newCanvas(Screen.width, Screen.height)
  self.players  = Conta()
  self.objects  = Conta()
  self.tiles    = Conta()

  -- Generate world
  local tw = Assets.getTilesize()
  for y = 1, Screen.height/tw do
    for x = 1, Screen.width/tw do
      local tile
      local pixelColor = {self.tileImage:getPixel(x-1, y-1)}
      for k,v in pairs(Assets.tileset.tiles) do
        if compare(pixelColor, v.pixelColor) then
          v.type = k
          tile = Tile(self, x*tw-tw, y*tw-tw, tw, v)
          if k == "player" then
            local player = Player(self, tile.pos.x, tile.pos.y)
            self.player = self.players:add(player)
          elseif k == "bug" then self.objects:add(Bug(self, tile.pos.x, tile.pos.y))
          elseif k == "exit" then self.objects:add(Exit(self, tile.pos.x, tile.pos.y)) end
        end
      end
      self.tiles:add(tile)
    end
  end
  -- Render level to canvas
  lg.setCanvas(self.canvas)
  self.tiles:draw()
  -- Draw overlay image
  if self.overlayImage then lg.draw(self.overlayImage) end
  lg.setCanvas()
end


function World:getPlayer(val)
  return self.players:get(val or 1)
end


function World:update(dt)
  self.objects:update(dt)
  self.tiles:update(dt)
  self.players:update(dt)
end


function World:draw()
  lg.draw(self.canvas)
  --self.tiles:draw() -- used later when animated tiles exist
  self.objects:draw()
  self.players:draw()
end

return World
