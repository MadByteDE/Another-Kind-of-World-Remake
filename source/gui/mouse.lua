
local Mouse = Class()
Mouse:include(Element)


local function getMousePosition()
  local mx, my = love.mouse.getPosition()
  return mx/Screen.scale, my/Screen.scale
end


function Mouse:init(x, y, t)
  local mx, my = getMousePosition(x, y)
  Element.init(self, mx, my, t)
  self.type     = "mouse"
  self.dim      = {w=1, h=1}
  self:newSprite(self.type, Assets.spritesheet, Assets.getQuad("sprite", {7, 2}))
  -- self:newSprite("hover", Assets.spritesheet, Assets.newQuad({7, 2}))
  self:setSprite(self.type)
  local _, _, qw, qh = self.sprite.quad:getViewport()
  self.trans.ox = qw/2
  self.trans.oy = qh/2
end


function Mouse:onEnter() end

function Mouse:onExit() end


function Mouse:setPosition(x, y)
  love.mouse.setPosition(x*Screen.scale, y*Screen.scale)
end


function Mouse:logic(dt)
  self.pos.x, self.pos.y = getMousePosition()
end

return Mouse
