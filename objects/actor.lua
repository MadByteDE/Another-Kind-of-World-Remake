-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Object = require("objects.object")
local Actor = Object:extend("actor")


function Actor:init(x, y, t)
    Object.init(self, x, y, t)
    -- Movement component
    self.vel        = self.vel or {x=0, y=0}
    self.max_vel    = self.max_vel or {x=150, y=150}
    self.acc        = self.acc or {x=50, y=80}
    self.gravity    = self.gravity or 33
    self.damp       = self.damp or {x=0, y=0}
    self.dir        = self.dir or {x=0, y=0}
    -- Properties
    self.damage_cooldown = 0
    self.health     = clamp(self.health or 0, 0, 999)
    self.max_health = clamp(self.max_health or 0, 0, 999)
    self.lifetime   = clamp(self.lifetime, 0, 999)
    self.bounciness = clamp(self.bounciness or 0, 0, 10)
    if self.wrap == nil then self.wrap = true end
    -- self.in_air = false
end


function Actor:filter(other)
    if not other.solid then return "cross" end
    if self.bounciness > 0 then return "bounce"
    else return "slide" end
end


function Actor:move(dt)
    local dx, dy = self.dir.x, self.dir.y
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
    local dx, dy = self.dir.x, self.dir.y
    -- x-axis
    if dx ~= 0 then self.vel.x = self.vel.x + (self.acc.x * dx * 10) * dt
    else self.vel.x = self.vel.x / (1 + self.damp.x * dt) end
    -- y-axis
    if dy ~= 0 then self.vel.y = self.vel.y + (self.acc.y * dy * 10) * dt
    else self.vel.y = self.vel.y / (1 + self.damp.y * dt) end
    if math.abs(self.vel.x) <= 0.01 then self.vel.x = 0 end
    if math.abs(self.vel.y) <= 0.01 then self.vel.y = 0 end
end


function Actor:heal(amount)
    checkType(amount, "number")
    self.health = math.min(self.max_health, self.health + amount)
end


function Actor:damage(amount, other)
    checkType(amount, "number")
    if self.damage_cooldown > 0 then return end
    self.damage_cooldown = 1
    self.health = math.max(0, self.health - amount)
    if self.onDamage then self:onDamage(amount, other) end
    if self.health <= 0 then self:onDead(other) end
end


function Actor:jump(vel)
    if not self.in_air then
        self.in_air = true
        self.vel.y = vel or -self.acc.y
        for i=1, math.random(2, 3) do
            local x, y = self:getCenter(0, 3)
            Game.level:spawn("particle", x, y, Game.assets.data.particles.dust)
            local pitch = math.random(75, 125)/100
            Game:playSound("jump", .7):setPitch(pitch)
        end
    end
end


function Actor:throw(name, data)
    checkType(name, "string")
    local mx, my = Game:getMousePosition()
    local cx, cy = self:getCenter()
    local dist_x = mx-(cx)
    local dist_y = my-(cy)
    local angle = math.sqrt(dist_x*dist_x + dist_y*dist_y)
    local data  = data or {}
    data.parent = self
    data.dx     = (mx-cx)/angle
    data.dy     = (my-cy)/angle
    Game.level:spawn(name, cx, cy, data)
    Game:playSound("toss")
    -- Pushback
    self.vel.x = self.vel.x + (random_range(70, 10) * -data.dx)
    self.vel.y = self.vel.y + (random_range(30, 15) * -data.dy)
end


function Actor:onDead()
    self:destroy()
end


function Actor:onCollision(other)
    if other.deadly and self.can_die then self:damage(999, other) end
end


function Actor:onDamage(amount, other)
    for i=1, math.random(5, 10) do
        local x, y = self:getCenter()
        Game.level:spawn("particle", x, y, Game.assets.data.particles.blood)
    end
    local pitch = math.random(75, 125)/100
    Game:playSound("splat"):setPitch(pitch)
end


function Actor:update(dt)
    Object.update(self, dt)
    self:accelerate(dt)
    -- wrap object around the screen
    if self.wrap then
        if self.x > Game.width then self.x = -self.width+2
        elseif self.x < -self.width then self.x = Game.width-2
        elseif self.y > Game.height then self.y = -self.height+2
        elseif self.y < -self.height then self.y = Game.height-2
        end
    end
    -- Update collsion rect
    self:updateCollider()
    -- Update lifetime
    if self.lifetime then
        self.lifetime = self.lifetime-dt
        if self.lifetime <= 0 then self:onDead() end
    end
    -- Update damage cooldown
    if self.damage_cooldown > 0 then
        self.damage_cooldown = self.damage_cooldown - dt
    else
        self.damage_cooldown = 0
    end
    -- Add gravity
    if self.vel.y > 0 then self.in_air = true end
    self.vel.y = self.vel.y + self.gravity * 10 * dt
    -- clamp speed to set limits
    self.vel.x = clamp(self.vel.x, -self.max_vel.x, self.max_vel.x)
    self.vel.y = clamp(self.vel.y, -self.max_vel.y, self.max_vel.y)
    -- calculate position
    local x = self.x + self.vel.x * dt
    local y = self.y + self.vel.y * dt
    -- Resolve collisions & update position
    if self.collider then
        local cols
        x, y, cols = Game.level.collision_world:move(self, x, y, self.filter)
        for k,col in ipairs(cols) do
            -- Reset velocities
            if col.type == "slide" then
                if col.other.y == self.y + self.height then
                    self.vel.y = 0
                    self.in_air = false
                elseif col.other.y + col.other.height == self.y then
                    self.vel.y = 0
                end
                if col.normal.x ~= 0 then
                    self.vel.x = 0
                end
            -- Apply bounciness
            elseif col.type == "bounce" then
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
    self.x, self.y = x, y
end

return Actor
