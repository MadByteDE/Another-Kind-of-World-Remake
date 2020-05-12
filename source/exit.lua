
local lg = love.graphics

local Screen  = require("source.screen")
local Assets  = require("source.assets")
local Actor   = require("source.actor")
local Class   = require("source.lib.class")
local Exit    = Class()
Exit:include(Actor)


function Exit:init(world, x, y)
  local tw = Assets.getTilesize()
  local iw, ih = Assets.tileset.image:getDimensions()
  Actor.init(self, world, x, y, {collides=true})
  self.type     = "exit"
  self.gravity  = 0
  self.quad     = lg.newQuad(tw*4, 0, tw, tw, iw, ih)
  self.visible  = false
  self.collides = false
end


function Exit:logic(dt)
  if self.visible then return end
  if #self.world.objects:get("bug") == 0 then
    self.visible  = true
    self.collides = true
  end
end


function Exit:draw()
  if not self.visible then return end
  lg.draw(Assets.tileset.image, self.quad, self.pos.x, self.pos.y)
  --self:drawRectangle("line")
end

return Exit
