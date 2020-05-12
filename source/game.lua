
local world, player

local Screen  = require("source.screen")
local Assets  = require("source.assets")
local World   = require("source.world")
local Game    = {}


function Game:init()
  Assets.audio.play("music", .35, true)
  world = World(0)
end


function Game:update(dt)
  player = world:getPlayer()
  world:update(dt)
end


function Game:draw()
  world:draw()
end


function Game:keypressed(key)
  if player then player:keypressed(key) end

  if key == "r" then
    Assets.audio.play("fail", .25)
    Screen:transition(function()
      if world.level == 10 then world:init(0)
      else world:init() end
    end, .75, {.1, .05, .05})
  end

  if key == "escape" then
    Screen:transition(function() love.event.quit() end, 3)
  end
end


function Game:mousereleased(x, y, button)
  if player then player:mousereleased(x, y, button) end
end

return Game
