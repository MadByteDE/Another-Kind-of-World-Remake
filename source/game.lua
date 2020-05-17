
local Game = {}


function Game:init(lvl)
  self.level  = lvl or self.level or 0
  self.world  = World(self.level)
  self.player = self.world:getObject("player")[1]
end


function Game:success()
  Assets.audio.play("success", .25)
  Screen:transition(function()
    self:init(self.world.id+1)
  end, 1)
end


function Game:fail()
  Assets.audio.play("fail", .30)
  Screen:transition(function()
    if self.level == 10 then self:init(0)
    else self:init() end
  end, .75, {.1, .05, .05})
end


function Game:update(dt)
  self.world:update(dt)
end


function Game:draw()
  self.world:draw()
end


function Game:keypressed(key)
  if self.player then self.player:keypressed(key) end
  if key == "r" then self:fail()
  elseif key == "escape" then
    Screen:transition(function() love.event.quit() end, 3)
  end
end


function Game:mousepressed(x, y, button)
end


function Game:mousereleased(x, y, button)
  if self.player then self.player:mousereleased(x, y, button) end
end

return Game
