-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Profiler = require("lib.profiler")
local Actor = require("objects.actor")
local Bug = Actor:extend("bug")


function Bug:init(x, y)
    -- Core
    self:setDimensions(6, 5)
    Actor.init(self, x, y+3, {collide=true, can_die=true, deadly=true})
    -- Properties
    self.tick   = {timer=0, delay=.3}
    self.acc    = {x=3, y=85}
    self.max_vel= {x=10, y=150}
    self.damp   = {x=.2, y=0}
    self.health = 50
    self.move_filter = function(other)
        if not other:instanceOf(Actor) then return "cross" end
    end
    self.points = {}
    -- Random movement direction when spawning
    local dir = love.math.random(1, 2)
    if dir == 1 then self.dir.x  = -1
    else self.dir.x = 1 end
    -- Add sprite(s)
    self:setSprite(self.name, {image=Game.assets.anim.bug, frames='1-6', row=1, duration=.15})
    self.sprite:gotoFrame(math.random(1, #self.sprite.frames))
    return self
end


function Bug:onCollision(other)
    if other.name ~= "bug" then
        Actor.onCollision(self, other)
    end
end


function Bug:queryEnvironment(dt)
    if Game.debug then Profiler:zone("Bug_EnvCol_Query") end
    local tw = Game.level.tilesize
    local dist  = {x=tw-2.5, y=tw}
    local cx, cy = self:getCenter()
    local x = cx + self.vel.x * dt
    local y = cy + self.vel.y * dt
    local w, h = self.width, self.height
    self.points = {}
    -- self.points.bottom={x=x, y=y+dist.y}
    if self.dir.x > 0 then
        self.points.top={x=x-(w/2)+.5, y=y-dist.y}
        self.points.right={x=x+dist.x, y=y}
        self.points.topright={x=x+dist.x, y=y-dist.y}
        self.points.bottomright={x=x+dist.x, y=y+dist.y}
        self.points.bottomright2={x=x+dist.x, y=y+(dist.y*2)}
    elseif self.dir.x < 0 then
        self.points.top={x=x+(w/2)-.5, y=y-dist.y}
        self.points.left={x=x-dist.x, y=y}
        self.points.topleft={x=x-dist.x, y=y-dist.y}
        self.points.bottomleft={x=x-dist.x, y=y+dist.y}
        self.points.bottomleft2={x=x-dist.x, y=y+(dist.y*2)}
    end
    local t = {}
    for key, point in pairs(self.points) do
        local cols = Game.level.collision_world:queryPoint(point.x, point.y, self.move_filter)
        if #cols > 0 then t[key] = cols[1] end
    end
    if Game.debug then Profiler:zone_pop() end
    return t
end


function Bug:logic(dt)
    if self.dir.x < 0 then self.sprite.flippedH = true
    else self.sprite.flippedH = false end
    -- Tick timer
    self.tick.timer = self.tick.timer - dt
    if self.tick.timer <= 0 then
        -- AI movement on platforms
        local x = self.x + self.vel.x * dt
        local y = self.y + self.vel.y * dt
        if self.in_air then return end
        local cols = self:queryEnvironment(dt)
        -- Jump
        if (not cols.top and not cols.topright and cols.right)
        or (not cols.top and not cols.topleft and cols.left) then
            self:jump()
        -- Turn around
        elseif self.dir.x > 0 then
            if (not cols.bottomright and not cols.bottomright2)
            or (cols.right)
            or (cols.bottomright and cols.bottomright.deadly) then
                if self.points.right.x < Game.width then self.dir.x = -1 end
            end
        elseif self.dir.x < 0 then
            if (not cols.bottomleft and not cols.bottomleft2)
            or (cols.left)
            or (cols.bottomleft and cols.bottomleft.deadly) then
                if self.points.left.x > 0 then self.dir.x = 1 end
            end
        end
        self.tick.timer = self.tick.delay
    end
end

-- function Bug:render() self:drawRectangle("line") end

return Bug
