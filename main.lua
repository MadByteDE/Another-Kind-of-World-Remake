
-- NAME            = "Another Kind of World (Remake)"
-- VERSION         = "1.3"
-- ORIGINAL_AUTHOR = "Markus Kothe (Daandruff)"
-- REMADE_BY       = "Lars Lönneker (MadByte)"


io.stdout:setvbuf("no")
love.graphics.setDefaultFilter("nearest", "nearest")
love.mouse.setVisible(false)
love.mouse.setGrabbed(true)
love.keyboard.setKeyRepeat(true)

-- Libs
Class  = require("source.lib.class")
Bump   = require("source.lib.bump")
Anim8  = require("source.lib.anim8")
Conta  = require("source.lib.conta")
-- Core
Assets  = require("source.assets")
Screen  = require("source.screen")
Gui     = require("source.gui")
Level   = require("source.level")
-- Entities
Object  = require("source.objects.object")
Actor   = require("source.objects.actor")
Tile    = require("source.objects.tile")
Entities = {
player   = require("source.objects.player"),
bug      = require("source.objects.bug"),
exit     = require("source.objects.exit"),
bomb     = require("source.objects.bomb"),
particle = require("source.objects.particle"),}
-- Gui elements
Element   = require("source.gui.element")
Elements  = {
mouse      = require("source.gui.mouse"),
button     = require("source.gui.button"),
textbox    = require("source.gui.textbox"),
tilepanel  = require("source.gui.tilepanel"),}
-- Scenes
Scene   = require("source.scenes.scene")
Game    = require("source.scenes.game")
Editor  = require("source.scenes.editor")

_NULL_ = function() end
CurrentScene = {init=_NULL_, update=_NULL_, draw=_NULL_, keypressed=_NULL_,
mousepressed=_NULL_, mousereleased=_NULL_}


-- Main callbacks
function love.load()
  love.graphics.setFont(Assets.fonts["normal"])
  Screen:init(256, 160, 4)
  Screen:transition(function()
    CurrentScene = Game
    CurrentScene:init()
    CurrentScene:getMouse():setPosition(Screen.width/2, Screen.height/2)
  end, 2)
  Assets.playSound("music", .275, true)
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
end


function love.keypressed(...) CurrentScene:keypressed(...) end

function love.keyreleased(...) CurrentScene:keyreleased(...) end

function love.mousepressed(...) CurrentScene:mousepressed(...) end

function love.mousereleased(...) CurrentScene:mousereleased(...) end

function love.wheelmoved(...) CurrentScene:wheelmoved(...) end

function love.textinput(...) CurrentScene:textinput(...) end
