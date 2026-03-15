-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Object = require("objects.object")
local Exit = Class()
Exit:include(Object)


function Exit:init(level, x, y, tile)
    -- Init
    Object.init(self, x, y, tile)
    self.type   = "exit"
    self.level  = level
    self.visible = false
    -- Additional
    self:newSprite(self.name, Game.assets.tile.exit)
    self:setSprite(self.name)
    Log:debug("Exit pos: %s, %s", self.pos.x, self.pos.y)
end


function Exit:logic(dt)
    if not self.visible and #self.level.objects:get("bug") == 0 then
        self.visible = true
        self.collide = true
        self:addCollider(self.level.collisionWorld)
    end
end

return Exit
