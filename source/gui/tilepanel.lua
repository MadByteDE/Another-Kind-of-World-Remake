
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


function Tilepanel:createTileButtons(gui)
  local tw = Assets.tilesize
  for i=1, #Assets.tiles do
    local rowsize = 3
    local spacing = 1
    local row     = math.floor((i-1)/rowsize)
    local column  = (i-1)%rowsize
    local x       = self.pos.x+2+column*tw+spacing*column
    local y       = self.pos.y+4+row*tw+spacing*row
    gui:add("button", x, y, {
      dim={w=tw, h=tw},
      quad = Assets.tiles[i].quad,
      parent = self,
      tile = Assets.tiles[i],
      action = function(e, button)
        CurrentScene.currentTile = e.tile
      end })
  end
end


function Tilepanel:getCurrentTile()
  return self.currentTile
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
