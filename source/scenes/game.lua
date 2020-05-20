
local Game = {}


function Game:init(lvl)
  self.level  = lvl or self.level or 0
  self.world  = World(self.level)
  self.gui    = Gui()
  self.gui:add("button", Screen.width-13, 5, {
    text = "Exit Game",
    action = function(button, mouse)
      Screen:transition(function() love.event.quit() end, 3)
    end,
  })
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
    if self.level == 11 then self:init(0)
    else self:init() end
  end, .75, {.1, .05, .05})
end


-- function Game:getMouse()
--   return self.gui:getMouse()
-- end


function Game:update(dt)
  self.world:update(dt)
  self.gui:update(dt)
end


function Game:draw()
  self.world:draw()
  self.gui:draw()
end


function Game:keypressed(key)
  if self.player then self.player:keypressed(key) end
  if key == "r" then self:fail()
  elseif key == "escape" then
    Screen:transition(function() love.event.quit() end, 3)
  end
end


function Game:mousepressed(x, y, button)
  self.gui:mousepressed(x, y, button)
end


function Game:mousereleased(x, y, button)
  local mouse = self.gui:getMouse()
  self.gui:mousereleased(x, y, button)
  if self.player and not mouse.hover then
    self.player:mousereleased(x, y, button)
  end
end

return Game
