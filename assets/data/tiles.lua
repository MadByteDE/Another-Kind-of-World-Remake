-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

return {
    {name="back",   type="tile"},
    {name="wall",   type="tile", collide=true, solid=true},
    {name="top",    type="tile", collide=true, solid=true},
    {name="under",  type="tile", collide=true, solid=true},
    {name="pillar", type="tile"},
    {name="drain",  type="tile", animdata={'1-8', 1, .05}, collide=true, solid=true},
    {name="grass",  type="tile", animdata={'1-4', 1, .2}, randomFrame=true},
    {name="water",  type="tile", animdata={'1-8', 1, .05}},
    {name="lava",   type="entity"},
    {name="exit",   type="entity"},
    {name="player", type="entity"},
    {name="bug",    type="entity"},
}