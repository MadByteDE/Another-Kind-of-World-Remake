
local utf8 = require("utf8")
local Textbox = Class()
Textbox:include(Element)


function Textbox:init(x, y, t)
  Element.init(self, x, y, t)
  self.type = "Textbox"
  self.text = self.text or ""
  self.action = self.action or function() end
  self.selectable = true
  self.textColor = {1, 1, 1, .75}
  self.rgba = {.05, .05, .05, .5}
  self.gui:select(self)
  self:setTimeout(4)
end


function Textbox:onEnter(mouse)
  Element.onEnter(self, mouse)
  self.gui:select(self)
end


function Textbox:onExit(mouse)
  Element.onExit(self, mouse)
  self:setTimeout(15)
end


function Textbox:onSelect()
  Element.onSelect(self)
  self.visible = true
end


function Textbox:onDeselect()
  Element.onDeselect(self)
  self:action()
  self.visible = false
  self.rgba = {.05, .05, .05, .5}
  self.textColor = {1, 1, 1, .75}
end


function Textbox:onTimeout()
end


function Textbox:onClick(Textbox, x, y)
end


function Textbox:onRelease(Textbox, x, y)
end


function Textbox:keypressed(key)
  if key == "backspace" then
    self:setTimeout(0)
    local byteoffset = utf8.offset(self.text, -1)
    if byteoffset then
        self.text = string.sub(self.text, 1, byteoffset-1)
    end
  end
end


function Textbox:onTextInput(text)
  local font = love.graphics.getFont()
  if font:getWidth(self.text) > self.dim.w-5 then return end
  self:setTimeout(0)
  self.text = self.text .. text:gsub('[%p%c%s]', '') -- remove symbols etc.
end


function Textbox:logic(dt)
end


function Textbox:render()
  self:drawRectangle("fill")
  local x = self.pos.x
  local y = self.pos.y+self.dim.h/2+.5
  Assets.print(self.text, x, y, {rgba=self.textColor, width=self.dim.w, mode="center"})
end

return Textbox
