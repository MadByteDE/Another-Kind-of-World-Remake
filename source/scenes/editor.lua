
local Editor  = Class()
Editor:include(Scene)

local tw = Assets.tilesize


function Editor:init()
  Scene.init(self)
  self.world  = World()
  self.currentTile = Assets.getTile("wall")
  -- Quit button
  self.gui:add("button", Screen.width-13, 3, {
    quad    = Assets.getButton("back"),
    action  = function(e, button)
      if button == 1 then
        Screen:transition(function() love.event.quit() end, 3)
      end
    end})
    -- Tile panel
    local panel = self.gui:add("tilepanel", 220, 50)
    panel:createTileButtons(self.gui)
    local x, y, w, h = panel.pos.x, panel.pos.y, panel.dim.w, panel.dim.h
    self.gui:add("button", x, y+h+1, {
      quad    = Assets.getButton("clear"),
      parent  = panel,
      action  = function(e, button)
        if button == 1 then
          Screen:transition(function() self.world = World() end, .5)
        end end })
    self.gui:add("button", x+11, y+h+1, {
      quad    = Assets.getButton("save"),
      parent  = panel, })
    self.gui:add("button", x+22, y+h+1, {
      quad    = Assets.getButton("play"),
      parent  = panel,
      action  = function(e, button)
        if button == 1 then
          Screen:transition(function()
            CurrentScene = Game
            CurrentScene:init()
          end, 2)
        end
      end })
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
  local tx, ty = self:toTileCoords(mouse.pos.x, mouse.pos.y)
  if love.mouse.isDown(1) and not mouse.child then
    local previous = self.world:getTile(tx, ty)
    self.world:setTile(tx, ty, Tile(self.world, tx*tw-tw, ty*tw-tw, self.currentTile))
    self.world:renderCanvas()
  elseif love.mouse.isDown(2) and not mouse.child then
    self.world:setTile(tx, ty, Tile(self.world, tx*tw-tw, ty*tw-tw, Assets.getTile("back")))
    self.world:renderCanvas()
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
