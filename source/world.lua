
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
  self.animatedTiles = Conta()

  -- Generate world
  local tw = Assets.getTilesize()
  for y = 1, Screen.height/tw do
    for x = 1, Screen.width/tw do
      local tile
      local pixelColor = {self.tileImage:getPixel(x-1, y-1)}
      for k,v in pairs(Assets.tileset.tiles) do
        if compare(pixelColor, v.pixelColor) then
          local x = x*tw-tw
          local y = y*tw-tw
          v.type = k
          if v.quad then self.tiles:add(Tile(self, x, y, tw, v))
          elseif v.anim then self.animatedTiles:add(Tile(self, x, y, tw, v)) end
          if k == "player" then
            self.player = self.players:add(Player(self, x, y))
          elseif k == "bug" then self.objects:add(Bug(self, x, y))
          elseif k == "exit" then self.objects:add(Exit(self, x, y)) end
        end
      end
    end
  end
  -- Render level to canvas
  lg.setCanvas(self.canvas)
  self.tiles:draw()
  if self.overlayImage then lg.draw(self.overlayImage) end
  lg.setCanvas()
end


function World:getPlayer(val)
  return self.players:get(val or 1)
end


function World:update(dt)
  self.objects:update(dt)
  self.animatedTiles:update(dt)
  self.players:update(dt)
end


function World:draw()
  lg.draw(self.canvas)
  self.animatedTiles:draw()
  self.objects:draw()
  self.players:draw()
end

return World
