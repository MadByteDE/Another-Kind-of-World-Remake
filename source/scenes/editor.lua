
local Editor  = Class()
Editor:include(Scene)

local tw


function Editor:init(id)
  Scene.init(self)

  -- Load level
  self.level = Level(id)
  tw = self.level.tileSize

  -- Pre-selected tile when entering editor mode
  self.currentTile = Assets.getTile("wall")

  -- Add tile panel
  local panel = self.gui:add("tilepanel", 220, 50)
  panel:createButtons()
  local data = {
    text = self.level.id,
    dim = {w=72,h=8},
    action = function(textbox)
      if textbox.text ~= "" then
        self.newLevelId = textbox.text
      end
    end, }
  local titleBox = self.gui:add("textbox", Screen.width/2-36, 2, data)
end


function Editor:toTileCoords(x, y)
  return math.floor(x/tw)+1, math.floor(y/tw)+1
end


function Editor:toScreenCoords(x, y)
  return x*tw-tw, y*tw-tw
end


function Editor:logic(dt)
  self.level:update(dt)
  local mouse = self:getMouse()
  local tx, ty = self:toTileCoords(mouse.pos.x, mouse.pos.y)
  if mouse.button == 1 then
    local previous = self.level:getTile(tx, ty)
    self.level:setTile(tx, ty, Tile(self.level, tx*tw-tw, ty*tw-tw, self.currentTile))
    self.level:renderCanvas()
  elseif mouse.button == 2 then
    self.currentTile = Assets.getTile(self.level:getTile(tx, ty).name)
  end
end


function Editor:render()
  self.level:draw()
  local mx, my = Screen:getMousePosition()
  local tx, ty = self:toTileCoords(mx, my)
  love.graphics.setColor(1, 1, 1, .3)
  if self.currentTile.quad then
    love.graphics.draw(Assets.spritesheet, self.currentTile.quad, tx*tw-tw, ty*tw-tw)
  end
  Assets.print("TAB - Switch to game\nLMB/RMB - Place/Pick tile\nSpace - Play level", 3, 2, {rgba={1, 1, 1, .075}, width=100})
end


function Editor:keypressed(key)
  self.gui:keypressed(key)

  if key == "escape" then
    Screen:transition(function() love.event.quit() end, 3)

  elseif key == "tab" then
    Screen:transition(function()
      CurrentScene = Game
      CurrentScene:init(0)
    end, 1.5)

  elseif key == "space" and not self.gui.selectedElement then
    Screen:transition(function()
      self.level:saveLevelData(self.newLevelId)
      CurrentScene = Game
      CurrentScene:init(self.level.id, true)
    end, 1)
  end
end

return Editor
