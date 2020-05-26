
local Tilepanel = Class()
Tilepanel:include(Element)


function Tilepanel:init(x, y, t)
  Element.init(self, x, y, t)
  self.type       = "tilepanel"
  self.draggable  = true
  self.rgba       = {1, 1, 1, .7}
  self:newSprite(self.type, Assets.spritesheet, Assets.getElement(self.type))
  self:setSprite(self.type)
  local _, _, qw, qh = self.sprite.quad:getViewport()
  self.dim = {w=qw, h=qh}
end


function Tilepanel:createButtons()
  local x, y, w, h = self.pos.x, self.pos.y, self.dim.w, self.dim.h
  -- Buttons for individual tiles
  local tw = Assets.tilesize
  for i=1, #Assets.tiles do
    local rowsize = 3
    local spacing = 1
    local row     = math.floor((i-1)/rowsize)
    local column  = (i-1)%rowsize
    local x       = self.pos.x+2+column*tw+spacing*column
    local y       = self.pos.y+4+row*tw+spacing*row
    -- Clear button
    local button = {quad = Assets.tiles[i].quad, parent = self}
    button.dim  = {w=tw, h=tw}
    button.tile  = Assets.tiles[i]
    button.action = function(button, pressed)
      if pressed == 1 then
        CurrentScene.currentTile = button.tile
      end
    end
    self._gui:add("button", x, y, button)
  end
  -- Clear button
  local button = {quad = Assets.getButton("clear"), parent = self}
  button.action = function(button, pressed)
    if pressed == 1 then
      Screen:transition(function() CurrentScene.world = World() end, .5)
    end
  end
  self._gui:add("button", x, y+h+1, button)
  -- Save button
  local button = {quad = Assets.getButton("save"), parent = self}
  button.action = function(button, pressed)
    if pressed == 1 then
      CurrentScene.world:save("saved")
      print("Successfully saved level")
    end
  end
  self._gui:add("button", x+11, y+h+1, button)
  -- Play button
  local button = {quad = Assets.getButton("play"), parent = self}
  button.action = function(button, pressed)
    if pressed == 1 then
      Screen:transition(function()
        CurrentScene.world:save("saved")
        CurrentScene = Game
        CurrentScene:init("saved")
      end)
    end
  end
  self._gui:add("button", x+22, y+h+1, button)
end


function Tilepanel:onEnter(mouse)
  Element.onEnter(self, mouse)
  self.rgba = {1, 1, 1, .9}
end


function Tilepanel:onExit(mouse)
  Element.onExit(self, mouse)
  self.rgba = {1, 1, 1, .7}
end


function Tilepanel:onClick(button, x, y)
  Element.onClick(self, button, x, y)
end


function Tilepanel:onRelease(button, x, y)
  Element.onRelease(self, button, x, y)
end


function Tilepanel:onScroll(x, y)
end


function Tilepanel:logic(dt)
end


function Tilepanel:render()
end

return Tilepanel
