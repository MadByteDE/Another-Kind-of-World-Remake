-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Object = require("objects.object")
local Tile = Object:extend("tile")


function Tile:init(x, y, tile)
    -- Core
    Object.init(self, x, y, tile)
    -- Add sprite(s)
    if self.animdata then
        self.animdata.image = Game.assets.anim[self.name]
        self:setSprite(self.name, self.animdata)
        if self.randomFrame then
            self.sprite:gotoFrame(love.math.random(1, #self.sprite.frames))
        end
    else
        self:setSprite(self.name, Game.assets.tile[self.name])
    end
end

-- function Tile:render() self:drawRectangle("line") end

return Tile
