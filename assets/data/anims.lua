-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local newAnimation = function(image, data)
    if not image then error("Animation image not set") end
    if not data then error("Animation data not set") end
    local frames, row, duration, onLoop = unpack(data)
    local g = Anim8.newGrid(8, 8, image:getWidth(), image:getHeight())
    return Anim8.newAnimation(g(frames, row), duration, onLoop)
end

return {
    ["player"] = newAnimation(Game.assets.anim.player, {'1-7', 1, .1}),
    ["bomb"]   = newAnimation(Game.assets.anim.bomb, {'1-4', 1, .1}),
    ["bug"]    = newAnimation(Game.assets.anim.bug, {'1-6', 1, .15}),
    ["grass"]  = newAnimation(Game.assets.anim.grass, {'1-4', 1, .2}),
    ["drain"]  = newAnimation(Game.assets.anim.drain, {'1-8', 1, .05}),
    ["water"]  = newAnimation(Game.assets.anim.water, {'1-8', 1, .05}),
}