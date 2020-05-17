
local Exit = Class()
Exit:include(Actor)
local tw      = Assets.getTilesize()
local iw, ih  = Assets.tileset.image:getDimensions()


function Exit:init(world, x, y)
  Actor.init(self, world, x, y, {gravity=0})
  self.type     = "exit"
  self.visible  = false
  self.quad     = lg.newQuad(tw*4, 0, tw, tw, iw, ih)
end


function Exit:logic(dt)
  if not self.visible and #self.world.objects:get("bug") == 0 then
    self.visible  = true
    self.collides = true
    self:addCollider()
  end
end


function Exit:draw()
  if not self.visible then return end
  lg.draw(Assets.tileset.image, self.quad, self.pos.x, self.pos.y)
end

return Exit
