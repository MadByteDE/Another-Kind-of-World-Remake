-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

return {
    {id=1,  name="back",    type="tile"},
    {id=2,  name="wall",    type="tile", collide=true, solid=true},
    {id=3,  name="top",     type="tile", collide=true, solid=true},
    {id=4,  name="under",   type="tile", collide=true, solid=true},
    {id=5,  name="pillar",  type="tile"},
    {id=6,  name="drain",   type="tile", animdata={'1-8', 1, .05}, collide=true, solid=true},
    {id=7,  name="grass",   type="tile", animdata={'1-4', 1, .2}, randomFrame=true},
    {id=8,  name="water",   type="tile", animdata={'1-8', 1, .05}},
    {id=9,  name="lava",    type="entity"},
    {id=10, name="exit",    type="entity"},
    {id=11, name="player",  type="entity"},
    {id=12, name="bug",     type="entity"},
}