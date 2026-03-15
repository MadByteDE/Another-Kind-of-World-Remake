-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Object = require("objects.object")
local Tile = Class()
Tile:include(Object)


function Tile:init(level, x, y, tile)
    for k,v in pairs(tile or {}) do self[k] = v end
    -- Init
    local tw = level.tileSize
    Object.init(self, x, y, {dim=tile.dim or {w=tw, h=tw}})
    -- Additional
    -- Remove properties used for the entity
    if self.type == "entity" then
        self.collide = false
        self.solid = false
    end
    -- Add collider
    if level and self.collide then self:addCollider(level.collisionWorld) end
    -- Add sprite
    if self.type == "animatedTile" then
        self:newSprite(self.name, Game.assets.anim[self.name], Game.assets.data.anims[self.name]:clone())
        self:setSprite(self.name)
        if self.randomFrame then
            self.sprite:gotoFrame(love.math.random(1, #self.sprite.frames))
        end
    else
        self:newSprite(self.name, Game.assets.tile[self.name])
        self:setSprite(self.name)
    end
end

return Tile
