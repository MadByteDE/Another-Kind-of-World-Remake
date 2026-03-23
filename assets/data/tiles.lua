-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

return {
    ["back"]    = { id = 1, name = "back",  type = "tile" },
    ["wall"]    = { id = 2, name = "wall",  type = "tile", collide = true, solid = true },
    ["top"]     = { id = 3, name = "top",   type = "tile", collide = true, solid = true },
    ["under"]   = { id = 4, name = "under", type = "tile", collide = true, solid = true },
    ["pillar"]  = { id = 5, name = "pillar", type = "tile" },
    ["drain"]   = { id = 6, name = "drain", type = "animatedTile", animdata = {'1-8', 1, .05}, collide = true, solid = true },
    ["grass"]   = { id = 7, name = "grass", type = "animatedTile", animdata = {'1-4', 1, .2}, randomFrame = true },
    ["water"]   = { id = 8, name = "water", type = "animatedTile", animdata = {'1-8', 1, .05} },
    ["lava"]    = { id = 9, name = "lava",  type = "tile", dim = {w=8, h=5},
                    trans = {r=0, sx=1, sy=1, ox=0, oy=3}, deadly = true, solid = true, collide = true },
    ["exit"]    = { id = 10, name = "exit", type = "entity" },
    ["player"]  = { id = 11, name = "player", type = "entity", collide = true, solid = true },
    ["bug"]     = { id = 12, name = "bug",  type = "entity", deadly = true, collide = true },
}