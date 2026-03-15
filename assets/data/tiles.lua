-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

return {
    { name = "back", type = "tile" },
    { name = "wall", type = "tile", collide = true, solid = true },
    { name = "top", type = "tile", collide = true, solid = true },
    { name = "under", type = "tile", collide = true, solid = true },
    { name = "pillar", type = "tile" },
    { name = "drain", type = "animatedTile", collide = true, solid = true },
    { name = "grass", type = "animatedTile", randomFrame = true },
    { name = "water", type = "animatedTile" },
    {
        name = "lava", type = "tile",
        dim = {w=8, h=5}, trans = {r=0, sx=1, sy=1, ox=0, oy=3},
        deadly = true, solid = true, collide = true
    },
    { name = "exit", type = "entity" },
    { name = "player", type = "entity", collide = true, solid = true },
    { name = "bug", type = "entity", deadly = true, collide = true },
}