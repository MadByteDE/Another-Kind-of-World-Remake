-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Anim8 = require("lib.anim8")
local Class = require("lib.30log")
local Object = Class("object")


function Object:init(x, y, t)
    for k,v in pairs(t or {}) do self[k] = v end
    -- Core
    self.name   = self.name or "object"
    self.rot    = self.rot or 0
    self.scale  = self.scale or {x=1, y=1}
    self.offset = self.offset or {x=0, y=0}
    self.rgba   = self.rgba or {1, 1, 1, 1}
    self:setDimensions(self.width or 8, self.height or 8)
    self:setPosition(x+self.offset.x, y+self.offset.y)
    -- Properties
    if self.visible == nil then self.visible = true end
    -- self.deadly = false
    -- self.solid  = false
    -- self.collide = false
    self.sprites = self.sprites or {}
    -- Undeclared
    -- self.sprite = self.sprite or nil
    -- self.collider = self.collider or nil
    -- Additional
    if self.collide then self:addCollider() end
end


function Object:filter(other)
    if self.solid and other.solid then return "slide" end
end


function Object:newSprite(name, image)
    self.sprites[name] = {
        image   = image,
        width   = image:getWidth(),
        height  = image:getHeight(),
        update  = _NULL,
        draw    = function(self, image, ...) love.graphics.draw(image or self.image, ...) end
    }
    return self.sprites[name]
end


function Object:newAnimation(name, image, frames, row, duration, onLoop)
    -- TODO: Replace hardcoded frame size with custom sizes for frames
    local w, h = 8, 8
    local g = Anim8.newGrid(w, h, image:getWidth(), image:getHeight())
    self.sprites[name] = Anim8.newAnimation(g(frames, row), duration, onLoop)
    self.sprites[name].image = image
    self.sprites[name].width = w
    self.sprites[name].height = h
    return self.sprites[name]
end


function Object:setSprite(name)
    self.sprite = self.sprites[name] or self.sprite
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


function Object:setPosition(x, y)
    self.x = x or self.x or 0
    self.y = y or self.y or 0
end


function Object:setDimensions(w, h)
    self.width = w or self.width or 8
    self.height = h or self.height or 8
end


function Object:getRect(x, y, w, h)
    local x, y = x or self.x, y or self.y
    local w, h = w or self.width, h or self.height
    return x, y, w, h
end


function Object:getCenter(ox, oy)
    local x = self.x+(ox or 0)+self.width/2
    local y = self.y+(oy or 0)+self.height/2
    return x, y
end


function Object:drawRectangle(mode)
    love.graphics.setColor(self.rgba)
    love.graphics.rectangle(mode or "fill", self.x, self.y, self.width, self.height)
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
            local r = self.rot
            local x, y = self.x, self.y
            local sx, sy = self.scale.x, self.scale.y
            local ox, oy = self.offset.x, self.offset.y
            local left = (self.sprite.width-self.width) / 2
            local top = (self.sprite.height-self.height)
            love.graphics.push()
            love.graphics.translate(-left, -top)
            love.graphics.setColor(self.rgba)
            self.sprite:draw(self.sprite.image, x, y, r, sx, sy, ox, oy)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.pop()
        end

        self:render()
    end
end

return Object
