
local Game = Class()
Game:include(Scene)


function Game:init(lvl)
  Scene.init(self)
  self.level  = lvl or self.level or 0
  self.world  = World(self.level)
  self.player = self.world:getObject("player")[1]
  -- Quit button
  self.gui:add("button", Screen.width-13, 3, {
    quad    = Assets.getButton("back"),
    action  = function(button)
      if button == 1 then Screen:transition(function() love.event.quit() end, 3) end
    end})
end


function Game:success()
  Assets.playSound("success", .25)
  Screen:transition(function()
    self:init(self.world.id+1)
  end, 1)
end


function Game:fail()
  Assets.playSound("fail", .30)
  Screen:transition(function()
    if self.level == 11 then self:init(0)
    else self:init() end
  end, .75, {.1, .05, .05})
end


function Game:logic(dt)
  self.world:update(dt)
end


function Game:render()
  self.world:draw()
end


function Game:keypressed(key)
  if self.player then self.player:keypressed(key) end
  if key == "r" then self:fail()
  elseif key == "escape" then
    Screen:transition(function() love.event.quit() end, 3)
  end
end


function Game:mousereleased(x, y, button)
  Scene.mousereleased(self, x, y, button)
  local mouse = self.gui:getMouse()
  if self.player and not mouse.child then
    self.player:mousereleased(x, y, button)
  end
end

return Game
