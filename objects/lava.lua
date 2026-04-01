-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Object = require("objects.object")
local Lava = Object:extend("lava")


function Lava:init(x, y, data)
    -- Core
    self:setDimensions(8, 5)
    Object.init(self, x, y+3, {deadly=true, collide=true})
    -- Add sprite(s)
    self:newSprite(self.name, Game.assets.tile.lava)
    self:setSprite(self.name)
end

return Lava
