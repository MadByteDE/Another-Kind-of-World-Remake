

local Scene = Class()


function Scene:init()
  self.gui = Gui()
end


function Scene:update(dt)
  self.gui:update(dt)
  self:logic(dt)
end


function Scene:getMouse()
  return self.gui:getMouse()
end


function Scene:draw()
  self:render()
  self.gui:draw(dt)
end

function Scene:logic(dt) end

function Scene:render() end

function Scene:mousepressed(...)
  self.gui:mousepressed(...)
end

function Scene:mousereleased(...)
  self.gui:mousereleased(...)
end

function Scene:keypressed(...)end

function Scene:keyreleased(...)end

return Scene
