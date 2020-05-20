
local Mouse = Class()
Mouse:include(Object)


local function getMousePosition(mx, my)
  local mx = mx or love.mouse.getX()
  local my = my or love.mouse.getY()
  return mx/Screen.scale, my/Screen.scale
end


function Mouse:init(x, y, t)
  local t = t or {}
  local mx, my = getMousePosition(x, y)
  Object.init(self, mx, my, t)
  self.type     = "mouse"
  self.dim      = t.dim or {w=1, h=1}
  self.hover    = false
  local sprite  = self:newSprite("cursor", Assets.spritesheet, Assets.newQuad({7, 2}))
  local _, _, qw, qh = sprite.quad:getViewport()
  self.trans.ox = qw/2
  self.trans.oy = qh/2
  self:setSprite("cursor")
end


function Mouse:setPosition(x, y)
  self.pos.x, self.pos.y = love.mouse.setPosition(getMousePosition(x, y))
end


function Mouse:logic(dt)
  -- Update position
  self.pos.x, self.pos.y = getMousePosition()
end

return Mouse
