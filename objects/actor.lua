-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Object = require("objects.object")
local Actor = Class()
Actor:include(Object)

local function clamp(val, min, max)
    if not val then return end
    return math.min(math.max(val, min), max)
end


function Actor:init(level, x, y, t)
    Object.init(self, x, y, t)
    -- Core
    self.level = level
    -- Movement component
    self.vel      = self.vel or {x=0, y=0, lx=150, ly=150}
    self.acc      = self.acc or {x=50, y=50}
    self.gravity  = self.gravity or 0
    self.damp     = self.damp or {x=0, y=0}
    self.dir      = self.dir or {x=0, y=0}
    -- Properties
    self.wrap       = self.wrap or true
    self.lifetime   = clamp(self.lifetime, 0, 999)
    self.in_air      = self.in_air or false
    self.bounciness = self.bounciness or 0
    -- Additional
    if self.collide then self:addCollider(self.level.collision_world) end
end


function Actor:move(dt)
    local dx,dy = self.dir.x, self.dir.y
    -- x-axis
    if dx ~= 0 then self.vel.x = (self.acc.x * dx * 10) * dt
    else if self.damp.x > 0 then
        self.vel.x = self.vel.x / (1 + self.damp.x * dt)
        else self.vel.x = 0 end
    end
    -- y axis
    if dy ~= 0 then self.vel.y = (self.acc.y * dy * 10) * dt
    else if self.damp.y > 0 then
        self.vel.y = self.vel.y / (1 + self.damp.y * dt)
        else self.vel.y = 0 end
    end
end


function Actor:accelerate(dt)
    local dx,dy = self.dir.x, self.dir.y
    -- x-axis
    if dx ~= 0 then self.vel.x = self.vel.x + (self.acc.x * dx * 10) * dt
    else self.vel.x = self.vel.x / (1 + self.damp.x * dt) end
    -- y-axis
    if dy ~= 0 then self.vel.y = self.vel.y + (self.acc.y * dy * 10) * dt
    else self.vel.y = self.vel.y / (1 + self.damp.y * dt) end
    if math.abs(self.vel.x) <= 0.01 then self.vel.x = 0 end
    if math.abs(self.vel.y) <= 0.01 then self.vel.y = 0 end
end


function Actor:applyGravity(dt)
    self.vel.y = self.vel.y + self.gravity * 10 * dt
end


function Actor:jump(vel)
    if not self.in_air then
        self.in_air = true
        self.vel.y = vel or -self.acc.y
    end
end


function Actor:onDead()
    self:destroy()
end


function Actor:onCollision(other)
    if other.deadly and self.canDie then self:onDead(other) end
end


function Actor:update(dt)
    Object.update(self, dt)
    -- wrap object around the screen
    if self.wrap then
        if self.pos.x > Game.width then
            self.pos.x = -self.dim.w+2
        elseif self.pos.x < -self.dim.w then
            self.pos.x = Game.width-2
        elseif self.pos.y > Game.height then
            self.pos.y = -self.dim.h+2
        elseif self.pos.y < -self.dim.h then
            self.pos.y = Game.height-2
        end
    end
    -- Update collsion rect
    self:updateCollider()
    -- Update lifetime
    if self.lifetime then
        self.lifetime = self.lifetime-dt
        if self.lifetime <= 0 then
            self:onDead()
            self.lifetime = nil
        end
    end
    -- Add gravity
    self:applyGravity(dt)
    -- clamp speed to set limits
    self.vel.x = clamp(self.vel.x, -self.vel.lx, self.vel.lx)
    self.vel.y = clamp(self.vel.y, -self.vel.ly, self.vel.ly)
    -- calculate position
    local x = self.pos.x + self.vel.x * dt
    local y = self.pos.y + self.vel.y * dt
    -- Resolve collisions & update position
    if self.collider then
        local cols
        x, y, cols = self.collision_world:move(self, x, y, self.filter)
        for k,col in ipairs(cols) do
            -- Reset velocities
            if col.type == "slide" then
                if col.other.pos.y == self.pos.y + self.dim.h then
                    self.vel.y = 0
                    self.in_air = false
                elseif col.other.pos.y + col.other.dim.h == self.pos.y then
                    self.vel.y = 0
                end
                if col.normal.x ~= 0 then
                    self.vel.x = 0
                end
            end
            -- Apply bounciness
            if col.type == "bounce" then
                local nx, ny = col.normal.x, col.normal.y
                if (nx < 0 and self.vel.x > 0) or (nx > 0 and self.vel.x < 0) then
                    self.vel.x = -self.vel.x * self.bounciness
                end
                if (ny < 0 and self.vel.y > 0) or (ny > 0 and self.vel.y < 0) then
                    self.vel.y = -self.vel.y * self.bounciness
                end
            end
            -- Apply additional changes if specified
            if self.onCollision then self:onCollision(col.other) end
        end
    end
    self.pos.x, self.pos.y = x, y
end

return Actor
