-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Anim8 = require("lib.anim8")

local Object = Class()


function Object:init(x, y, t)
    for k,v in pairs(t or {}) do self[k] = v end
    -- Core
    self.type     = self.type or "object"
    self.trans    = self.trans or {r=0, sx=1, sy=1, ox=0, oy=0}
    self.dim      = self.dim or {w=8, h=8}
    self.pos      = {x = (x + self.trans.ox) or 0, y = (y + self.trans.oy) or 0}
    self.rgba     = self.rgba or {1, 1, 1, 1}
    -- Properties
    self.visible  = self.visible or true
    self.deadly   = self.deadly or false
    self.solid    = self.solid or false
    self.collide  = self.collide or false
    self.sprites  = self.sprites or {}
    -- Undeclared
    self.sprite   = self.sprite or nil
    self.collider = self.collider or nil
    -- Additional   
    if self.collide then self:addCollider() end
end


function Object:newSprite(name, image)
    self.sprites[name] = {
        image   = image,
        update  = _NULL,
        draw    = function(self, image, ...) love.graphics.draw(image or self.image, ...) end
    }
    return self.sprites[name]
end


function Object:newAnimation(name, image, frames, row, duration, onLoop)
    local g = Anim8.newGrid(8, 8, image:getWidth(), image:getHeight())
    self.sprites[name] = Anim8.newAnimation(g(frames, row), duration, onLoop)
    self.sprites[name].image = image
    return self.sprites[name]
end


function Object:setSprite(name)
    self.sprite = self.sprites[name] or self.sprite
end


function Object:filter(other)
    if self.solid and other.solid then return "slide"
    else return "cross" end
end


function Object:addCollider(x, y, w, h)
    if self.collider then return end
    local x, y, w, h = self:getRect()
    Game.level.collision_world:add(self, x, y, w, h, self.filter)
    self.collider = Game.level.collision_world:getRect(self)
end


function Object:removeCollider()
    if not self.collider then return end
    Game.level.collision_world:remove(self)
    self.collider = nil
end


function Object:updateCollider()
    if not self.collider then return end
    local x, y, w, h = self:getRect()
    Game.level.collision_world:update(self, x, y, w, h)
end


function Object:getRect(x, y, w, h)
    local x, y = x or self.pos.x, y or self.pos.y
    local w, h = w or self.dim.w, h or self.dim.h
    return x, y, w, h
end


function Object:getCenter(ox, oy)
    local x = self.pos.x+(ox or 0)+self.dim.w/2
    local y = self.pos.y+(oy or 0)+self.dim.h/2
    return x, y
end


function Object:drawRectangle(mode)
    love.graphics.setColor(self.rgba)
    love.graphics.rectangle(mode or "fill", self.pos.x, self.pos.y, self.dim.w, self.dim.h)
    love.graphics.setColor(1, 1, 1, 1)
end


function Object:destroy()
    self.removed = true
    self:removeCollider()
end


function Object:logic(dt) end


function Object:update(dt)
    if self.removed then return end
    -- update additional game logic
    self:logic(dt)
    -- update the sprite / animation
    if self.sprite then self.sprite:update(dt) end
end


function Object:render() end


function Object:draw()
    if self.visible then

        if self.sprite then
            local r = self.trans.r
            local x, y = self:getRect()
            local sx, sy = self.trans.sx, self.trans.sy
            local ox, oy = self.trans.ox, self.trans.oy
            love.graphics.setColor(self.rgba)
            self.sprite:draw(self.sprite.image, x, y, r, sx, sy, ox, oy)
            love.graphics.setColor(1, 1, 1, 1)
        end

        self:render()
    end
end

return Object
