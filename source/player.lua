
local Player  = Class()
Player:include(Actor)


function Player:init(world, x, y)
  local t = {collides=true, isSolid=true}
  Actor.init(self, world, x+1, y+1, t)
  self.type     = "player"
  self.dim      = {w=6, h=7}
  self.trans    = {r=0, sx=1, sy=1, ox=1, oy=1}
  self.acc      = {x=40,y=125}
  self.vel      = {x=0,y=0,lx=80,ly=120}
  self.damp     = {x=30,y=0}
  self.gravity  = 30
  self.canDie   = true
  self:newSprite("idle", '1-6', 1, .1)
  self:setSprite("idle")
end


function Player:onDead(v)
  Actor.onDead(self)
  Game:fail()
end


function Player:onCollision(col)
  local other = col.other
  if other.type == "bug" then
    self:onDead()
  elseif other.type == "exit" and other.collides then
    self:destroy()
    Game:success()
  end
end


function Player:logic(dt)
  local keyDown = love.keyboard.isDown
  -- always reset direction
  self.dir.x = 0
  self.dir.y = 0
  -- Key movement
  if keyDown("a") or keyDown("left")  then
    self.sprite.flippedH = true
    self.dir.x = -1
  end
  if keyDown("d") or keyDown("right") then
    self.sprite.flippedH = false
    self.dir.x = 1
  end
  self:accelerate(dt) -- accelerate instead of moving at a constant speed
end


function Player:keypressed(key)
  if key == "w" or key == "up" or key == "space" then
    if not self.inAir then Assets.audio.play("jump") end
    self:jump()
  end
end


function Player:mousereleased(x, y, button)
  if button == 1 and #self.world:getObject("bomb") < 3 then
    self.world:spawn("bomb", x/Screen.scale, y/Screen.scale, self)
  end
end

return Player
