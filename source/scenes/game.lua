
local Game = Class()
Game:include(Scene)


function Game:init(id, isEditorLevel)
  Scene.init(self)
  self.currentId = id or self.currentId or 0
  self.level = Level(self.currentId)
  self.isEditorLevel = isEditorLevel or false
  self.player = self.level:getObject("player")[1]
  print("Col Obj: "..self.level.collisionWorld:countItems())
  print("Anim Obj: "..#self.level.animatedTiles:get())
  print("Ent Obj: "..#self.level.objects:get())
end


function Game:success()
  Assets.playSound("success", .7)
  Screen:transition(function()
    if self.isEditorLevel then CurrentScene = Editor
    else self:init(tonumber(self.level.id)+1) end
  end, 1)
end


function Game:fail()
  Assets.playSound("fail", .7)
  Screen:transition(function()
    if tonumber(self.level.id) == 12 then self:init(0)
    else self:init() end
  end, .75, {.1, .05, .05})
end


function Game:logic(dt)
  self.level:update(dt)
end


function Game:render()
  self.level:draw()
  Assets.print("'TAB' - Switch to editor", 3, 2, {1, 1, 1, .075})
end


function Game:keypressed(key)
  if self.player then self.player:keypressed(key) end
  if key == "r" then self:fail()
  elseif key == "tab" then
    Screen:transition(function()
      CurrentScene = Editor
      if self.isEditorLevel then CurrentScene = Editor
      else CurrentScene:init(self.level.id) end
    end, 1)
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
