
local Screen = {}
local transAlpha  = 0
local transTime   = 0
local transTimer  = 0
local shakeTime   = 0
local onTransition, triggered, rgb


function Screen:init(width, height, scale)
  self.width   = width  or 800
  self.height  = height or 600
  self.scale   = scale  or 1
end


function Screen:getMousePosition()
  local mx, my = love.mouse.getPosition()
  return mx/self.scale, my/self.scale
end


function Screen:shake(time)
  shakeTime = time or .35
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
  if shakeTime > 0 then shakeTime = shakeTime - dt
  else shakeTime = 0 end
  if transTimer > 0 then
    transTimer = transTimer - dt
  else transTimer = 0 end
  if transTimer < transTime/2 and not triggered then
    onTransition()
    triggered = true
  end
  local elapsed = transTime-transTimer
  transAlpha = elapsed/transTime*transTimer/(transTime/4)
end


function Screen:set()
  love.graphics.push()
  local shakeX = math.floor(math.random(-shakeTime, shakeTime))
  local shakeY = math.floor(math.random(-shakeTime, shakeTime))
  love.graphics.translate(shakeX*2, shakeY*2)
  love.graphics.scale(self.scale, self.scale)
end


function Screen:unset()
  love.graphics.setColor(rgb[1], rgb[2], rgb[3], transAlpha)
  love.graphics.rectangle("fill", 0, 0, self.width, self.height)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.pop()
end

return Screen
