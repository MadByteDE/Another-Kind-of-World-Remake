
local Editor  = Class()
Editor:include(Scene)

local tw      = Assets.tilesize
local tick    = 1/60
local time    = 0


function Editor:init()
  Scene.init(self)
  self.world  = World()
  self.currentTile = Assets.getTile("wall")
  -- Quit button
  self.gui:add("button", Screen.width-13, 3, {
    quad    = Assets.getButton("back"),
    action  = function(button)
      if button == 1 then
        Screen:transition(function() love.event.quit() end, 3)
      end
    end})
end


function Editor:toTileCoords(x, y)
  return math.floor(x/tw)+1, math.floor(y/tw)+1
end


function Editor:toScreenCoords(x, y)
  return x*tw-tw, y*tw-tw
end


function Editor:logic(dt)
  self.world:update(dt)
  local mouse = self:getMouse()
  time = time - dt
  if time <= 0 then
    local tx, ty = self:toTileCoords(mouse.pos.x, mouse.pos.y)
    if love.mouse.isDown(1) and not mouse.child then
      local previous = self.world:getTile(tx, ty)
      self.world:setTile(tx, ty, Tile(self.world, tx*tw-tw, ty*tw-tw, self.currentTile))
      self.world:renderCanvas()
    elseif love.mouse.isDown(2) then
      self.world:setTile(tx, ty, Tile(self.world, tx*tw-tw, ty*tw-tw, Assets.getTile("back")))
      self.world:renderCanvas()
    end
    time = tick
  end
end


function Editor:render()
  self.world:draw()
  local mx, my = Screen:getMousePosition()
  local tx, ty = self:toTileCoords(mx, my)
  lg.setColor(1, 1, 1, .3)
  if self.currentTile.quad then
    lg.draw(Assets.spritesheet, self.currentTile.quad, tx*tw-tw, ty*tw-tw)
  end
  lg.setColor(1, 1, 1, 1)
end


function Editor:keypressed(key)
  if key == "escape" then
    Screen:transition(function() love.event.quit() end, 3)
  end
end

return Editor
