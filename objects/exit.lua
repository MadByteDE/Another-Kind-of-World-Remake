-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Object = require("objects.object")
local Exit = Object:extend("exit")


function Exit:init(x, y, tile)
    -- Core
    Object.init(self, x, y)
    -- Properties
    self.visible = false
    -- Add sprite(s)
    self:setSprite(self.name, Game.assets.tile.exit)
end


function Exit:logic(dt)
    if not self.visible and #Game.level:getObject("bug") == 0 then
        self.visible = true
        self.collide = true
        self:addCollider()
        for i=1, math.random(10, 15) do
            local x, y = self:getCenter()
            Game.level:spawn("particle", x, y, Game.assets.data.particles.glitter)
        end
    end
end

-- function Exit:render() self:drawRectangle("line") end

return Exit
