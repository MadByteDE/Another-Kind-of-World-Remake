
local Game = Class()
Game:include(Scene)


function Game:init(lvl)
  Scene.init(self)
  self.level  = lvl or self.level or 0
  self.world  = World(self.level)
  self.player = self.world:getObject("player")[1]
end


function Game:success()
  Assets.playSound("success", .7)
  Screen:transition(function()
    if type(self.world.id) == "string" then CurrentScene = Editor
    else self:init(self.world.id+1) end
  end, 1)
end


function Game:fail()
  Assets.playSound("fail", .7)
  Screen:transition(function()
    if self.level == 12 then self:init(0)
    else self:init() end
  end, .75, {.1, .05, .05})
end


function Game:logic(dt)
  self.world:update(dt)
end


function Game:render()
  self.world:draw()
  Assets.print("'TAB' - Switch to editor", 3, 2, {1, 1, 1, .075})
end


function Game:keypressed(key)
  if self.player then self.player:keypressed(key) end
  if key == "r" then self:fail()
  elseif key == "tab" then
    Screen:transition(function()
      CurrentScene = Editor
      CurrentScene:init()
    end, 1.5)
  elseif key == "escape" then
    Screen:transition(function() love.event.quit() end, 3)
  end
end


function Game:keyreleased(key)
  if self.player then self.player:keyreleased(key) end
end


function Game:mousereleased(x, y, button)
  Scene.mousereleased(self, x, y, button)
  local mouse = self.gui:getMouse()
  if self.player then self.player:mousereleased() end
end

return Game
