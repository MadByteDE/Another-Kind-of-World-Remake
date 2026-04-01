-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Scene = require("scenes.scene")
local Ingame = Scene:extend("ingame")


function Ingame:init(id, editor_level)
    self.name = "ingame"
    self.editor_level = editor_level or false
    Game.level:load(id or Game.level.id)
    self.players = Game.level:getObject("player")
    if Game.debug then
        Log:debug("Col Obj: "..Game.level.collision_world:countItems())
        Log:debug("Anim Obj: "..#Game.level.animated_tiles:get())
        Log:debug("Ent Obj: "..#Game.level.objects:get())
    end
end


function Ingame:success()
    Game:playSound("success", .7)
    Game:transition(function()
        if self.editor_level then Game:switchScene("editor")
        else self:init(Game.level.id+1) end
    end, 1)
end


function Ingame:fail()
    Game:playSound("fail", .7)
    Game:transition(function()
        if Game.level.id == 12 then self:init(0)
        else self:init() end
    end, .75, {.1, .05, .05})
end


function Ingame:render()
    Game:print("'TAB' - Switch to editor", 1, 10, {1, 1, 1, .1})
end


function Ingame:keypressed(key)
    if key == "r" then
        self:fail()
    elseif key == "tab" then
        Game:transition(function() Game:switchScene("editor", Game.level.id) end, 1)
    elseif key == "escape" then
        Game:transition(function() love.event.quit() end, 3)
    end
    for k, player in ipairs(self.players) do player:keypressed(key) end
end


function Ingame:keyreleased(key)
    for k, player in ipairs(self.players) do player:keyreleased(key) end
end


function Ingame:mousereleased(x, y, button)
    Scene.mousereleased(self, x, y, button)
    for k, player in ipairs(self.players) do player:mousereleased(x, y, button) end
end

return Ingame
