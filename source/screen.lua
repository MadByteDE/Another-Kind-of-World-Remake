
local Screen = {}

local transAlpha = 0
local transTime = 0
local transTimer = 0
local shakeTime = 0
local onTransition, triggered, rgb


function Screen:init(w, h, s)
  self.width   = w or 800
  self.height  = h or 600
  self.scale   = s or 1
end


function Screen:shake(time)
  shakeTime = time or .5
end


function Screen:transition(action, time, color)
  if transTimer ~= 0 then return end
  transTime   = time or 2
  transTimer  = transTime
  triggered   = false
  rgb         = color or {.05, .05, .05}
  onTransition = action or function()end
end


function Screen:update(dt)
  if shakeTime > 0 then shakeTime = shakeTime - dt end
  if shakeTime < 0 then shakeTime = 0 end
  if transTimer > 0 then
    transTimer = transTimer - dt
  end
  if transTimer < transTime/2 and not triggered then
    onTransition()
    triggered = true
  end
  if transTimer < 0 then transTimer = 0 end
  local elapsed = transTime-transTimer
  transAlpha = elapsed/transTime*transTimer/(transTime/4)
end


function Screen:set()
  love.graphics.push()
  local shakeX = math.floor(math.random(-shakeTime, shakeTime))
  local shakeY = math.floor(math.random(-shakeTime, shakeTime))
  love.graphics.translate(shakeX*3, shakeY*3)
  love.graphics.scale(self.scale, self.scale)
end


function Screen:unset()
  love.graphics.setColor(rgb[1], rgb[2], rgb[3], transAlpha)
  love.graphics.rectangle("fill", 0, 0, self.width, self.height)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.pop()
end

return Screen
