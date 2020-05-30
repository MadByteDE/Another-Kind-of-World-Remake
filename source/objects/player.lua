
local Player  = Class()
Player:include(Actor)


function Player:init(world, x, y)
  -- Init
  Actor.init(self, world, x, y, {collide=true, solid=true, canDie=true})
  self.type     = "player"
  self.dim      = {w=6, h=7}
  self.trans    = {r=0, sx=1, sy=1, ox=1, oy=1}
  self.acc      = {x=35,y=147}
  self.vel      = {x=0,y=0,lx=70,ly=130}
  self.damp     = {x=30,y=0}
  self.gravity  = 33
  -- Additional
  self:newSprite(self.type, Assets.spritesheet, Assets.getAnimation(self.type))
  self:setSprite(self.type)
end


function Player:onDead(v)
  Actor.onDead(self)
  Game:fail()
end


function Player:onCollision(other)
  Actor.onCollision(self, other)
  if other.type == "exit" then
    self:destroy()
    Game:success()
  end
end


function Player:logic(dt)
  local mouse = Game:getMouse()
  local keyDown = love.keyboard.isDown
  -- always reset direction
  self.dir.x = 0
  self.dir.y = 0
  -- Look towards the cursor
  if mouse.pos.x > self.pos.x+self.dim.w/2 then
   self.sprite.flippedH = false
 else self.sprite.flippedH = true end
  -- Prevent jumping while in air
  if self.vel.y > 50 then self.inAir = true end
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
    if not self.inAir then Assets.playSound("jump", .7) end
    self:jump()
  end
end


function Player:keyreleased(key)
  if key == "w" or key == "up" or key == "space" then
    self.vel.y = self.vel.y/1.6
  end
end


function Player:mousereleased()
  local mouse = CurrentScene:getMouse()
  if mouse.button == 1 and #self.world:getObject("bomb") < 3 then
    self.world:spawn("bomb", mouse.pos.x-self.dim.w, mouse.pos.y, self)
    Assets.playSound("toss")
  end
end

return Player
