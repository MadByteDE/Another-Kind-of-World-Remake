
local _Another_Kind_of_World = {
  _VERSION          = '1.3.0',
  _ORIGINAL_AUTHOR  = 'Markus Kothe (Daandruff)',
  _REMADE_BY        = 'Lars Lönneker (MadByte)',
}

io.stdout:setvbuf("no")
love.graphics.setDefaultFilter("nearest", "nearest")
love.mouse.setVisible(false)
love.mouse.setGrabbed(true)

-- Dependencies
local Assets  = require("source.assets")
local Screen  = require("source.screen")
local Game    = require("source.game")

-- Locals
local callbacks = {"init", "update", "draw", "keypressed", "mousereleased"}
local Scene = {}
for i=1, #callbacks do Scene[callbacks[i]] = function()end end
local cursor = Assets.newQuad(7, 2)

-- Local functions
local function drawCursor()
  local mx, my  = love.mouse.getPosition()
  local scale   = Screen.scale
  love.graphics.draw(Assets.sprite.image, cursor, mx-4, my-4, 0, scale, scale)
end

local function drawDirtCover()
  love.graphics.setColor(1, 1, 1, .5)
  love.graphics.draw(Assets.image["dirtcover"])
  love.graphics.setColor(1, 1, 1, 1)
end


-- Main callbacks
function love.load()
  Screen:init(256, 160, 3)
  Screen:transition(function() Scene = Game; Scene:init() end, 2)
end


function love.update(dt)
  Screen:update(dt)
  Scene:update(dt)
end


function love.draw()
  Screen:set()
  Scene:draw()
  Screen:unset()
  drawDirtCover()
  drawCursor()
  -- love.graphics.print("FPS: "..love.timer.getFPS())
end


function love.keypressed(key)
  Scene:keypressed(key)
end

function love.mousereleased(...)
  Scene:mousereleased(...)
end
