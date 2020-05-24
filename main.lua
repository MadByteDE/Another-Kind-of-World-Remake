--[[
      NAME            = "Another Kind of World (Remake)"
      VERSION         = "1.2.5"
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
lt = love.timer
-- Libs
Class  = require("source.lib.class")
Bump   = require("source.lib.bump")
Anim8  = require("source.lib.anim8")
Conta  = require("source.lib.conta")
-- Core
Assets  = require("source.assets")
Screen  = require("source.screen")
Gui     = require("source.gui")
World   = require("source.world")
-- Objects
Object  = require("source.objects.object")
Actor   = require("source.objects.actor")
Tile    = require("source.objects.tile")
Entities = {}
Entities.player   = require("source.objects.player")
Entities.bug      = require("source.objects.bug")
Entities.exit     = require("source.objects.exit")
Entities.bomb     = require("source.objects.bomb")
Entities.particle = require("source.objects.particle")
-- Gui elements
Element   = require("source.gui.element")
Elements  = {}
Elements.mouse      = require("source.gui.mouse")
Elements.button     = require("source.gui.button")
Elements.tilepanel  = require("source.gui.tilepanel")
-- Scenes
Scene   = require("source.scenes.scene")
Game    = require("source.scenes.game")
Editor  = require("source.scenes.editor")

_NULL_ = function() end
CurrentScene = {init=_NULL_, update=_NULL_, draw=_NULL_, keypressed=_NULL_,
mousepressed=_NULL_, mousereleased=_NULL_}

-- Main callbacks
function love.load()
  Screen:init(256, 160, 3)
  Screen:transition(function()
    CurrentScene = Game
    CurrentScene:init()
    CurrentScene:getMouse():setPosition(Screen.width/2, Screen.height/2)
  end, 2)
  Assets.playSound("music", .35, true)
end


function love.update(dt)
  Screen:update(dt)
  CurrentScene:update(dt)
end


function love.draw()
  Screen:set()
  CurrentScene:draw()
  Screen:unset()
  Assets.drawDirtCover(Screen.scale)
  -- lg.print("FPS: "..lt.getFPS(), 10, 10)
  -- lg.print("MEM: "..math.floor(collectgarbage("count")).."kb", 10, 25)
  lg.setColor(.5, .5, .5, .2)
  lg.print("'TAB' - Switch Editor/Game mode", 10, 10)
  lg.print("'ESC' - Quit", 10, 25)
  if CurrentScene == Editor then
    lg.print("'LMB' - Place selected tile", 10, 50)
    lg.print("'RMB' - Pick tile from map", 10, 65)
  end
  lg.setColor(1, 1, 1, 1)
end


function love.keypressed(...)
  CurrentScene:keypressed(...)
end


function love.mousepressed(...)
  CurrentScene:mousepressed(...)
end


function love.mousereleased(...)
  CurrentScene:mousereleased(...)
end
