--[[
      NAME            = "Another Kind of World (Remake)"
      VERSION         = "1.2.0"
      ORIGINAL_AUTHOR = "Markus Kothe (Daandruff)"
      REMAKE_BY       = "Lars Lönneker (MadByte)"
]]--

io.stdout:setvbuf("no")
love.graphics.setDefaultFilter("nearest", "nearest")
love.mouse.setVisible(false)

-- Shortcuts
la = love.audio
lf = love.filesystem
li = love.image
lg = love.graphics
-- Libs
Class   = require("source.lib.class")
Bump    = require("source.lib.bump")
Anim8   = require("source.lib.anim8")
Conta   = require("source.lib.conta")
-- Game dependencies
Screen  = require("source.screen")
Assets  = require("source.assets")
Actor   = require("source.actor")
Tile    = require("source.tile")
World   = require("source.world")
-- States
Game    = require("source.game")
Editor  = require("source.editor")

-- Locals
local _NULL_  = function()end
local Scene   = {init=_NULL_, update=_NULL_, draw=_NULL_, keypressed=_NULL_,
mousepressed=_NULL_, mousereleased=_NULL_}
local cursor  = Assets.newQuad(7, 2)


-- Main callbacks
function love.load()
  Screen:init(256, 160, 3)
  Screen:transition(function() Scene = Game; Scene:init() end, 2)
  Assets.audio.play("music", .35, true)
end


function love.update(dt)
  Screen:update(dt)
  Scene:update(dt)
end


function love.draw()
  Screen:set()
  Scene:draw()
  Screen:unset()
  Assets.drawDirtCover()
  Assets.drawCursor(cursor)
  -- lg.print("FPS: "..love.timer.getFPS(), 10, 10)
end


function love.keypressed(...)
  Scene:keypressed(...)
end


function love.mousepressed(...)
  Scene:mousepressed(...)
end


function love.mousereleased(...)
  Scene:mousereleased(...)
end
