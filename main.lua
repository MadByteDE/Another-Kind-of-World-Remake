--[[
      NAME            = "Another Kind of World (Remake)"
      VERSION         = "1.2.0"
      ORIGINAL_AUTHOR = "Markus Kothe (Daandruff)"
      REMADE_BY       = "Lars Lönneker (MadByte)"
]]--

io.stdout:setvbuf("no")
love.graphics.setDefaultFilter("nearest", "nearest")
love.mouse.setVisible(false)
love.mouse.setGrabbed(true)

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
-- Basics
Assets  = require("source.assets")
Screen  = require("source.screen")
-- Objects
Object  = require("source.objects.object")
Actor   = require("source.objects.actor")
Tile    = require("source.objects.tile")
World   = require("source.world")
-- Gui
Element = require("source.gui.element")
Mouse   = require("source.gui.mouse")
Gui     = require("source.gui")
-- States
Scene   = require("source.scenes.scene")
Game    = require("source.scenes.game")
Editor  = require("source.scenes.editor")

-- Locals
local NULL   = function()end
local Scene   = {init=NULL, update=NULL, draw=NULL, keypressed=NULL,
mousepressed=_NULL, mousereleased=NULL}


-- Main callbacks
function love.load()
  Screen:init(256, 160, 3)
  Screen:transition(function()
    Scene = Game
    Scene:init()
    Scene:getMouse():setPosition(Screen.width/2, Screen.height/2)
  end, 2)
  Assets.playSound("music", .35, true)
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
  -- lg.print("FPS: "..love.timer.getFPS(), 10, 10)
  -- lg.print("MEM: "..math.floor(collectgarbage("count")).."kb", 10, 20)
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
