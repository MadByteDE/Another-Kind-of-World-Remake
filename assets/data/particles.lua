-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Actor = require("objects.actor")

return {
    ["glitter"] = {
        images={Game.assets.particle.glitter},
        collide=true, wrap=true, bounciness=.4, damp={x=2, y=0},
        lifetime=1.5, range={x={-60, 60}, y={-50, -80}},
        filter=function(self, other)
            if other:instanceOf(Actor) then return "cross"
            else return "bounce" end
        end
    },

    ["blood"] = {
        images={Game.assets.particle.blood},
        lifetime=.5, wrap=false, range={x={-25, 25}, y={-40, -80}},
    },

    ["explosion"] = {
        images={Game.assets.particle.smoke, Game.assets.particle.fire},
        lifetime=.8, wrap=false, range={x={-25, 25}, y={-50, -100}},
    },

    ["dust"] = {
        images={Game.assets.particle.dust},
        collide=true, wrap=true, bounciness=.5, damp={x=2, y=0},
        lifetime=1.5, range={x={-25, 25}, y={-30, -50}}, gravity=20,
        filter=function(self, other)
            if other:instanceOf(Actor) then return "cross"
            else return "bounce" end
        end
    },
}