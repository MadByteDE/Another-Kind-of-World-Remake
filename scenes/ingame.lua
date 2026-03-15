-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Scene = require("scenes.scene")
local Ingame = Class()
Ingame:include(Scene)


function Ingame:init(id, editor_level)
    self.name = "Ingame"
    Game.level:init(id)
    self.editor_level = editor_level or false
    self.players = Game.level:getObject("player")
    self.player = self.players[1]
    if Game.debug then
        Log:debug("Col Obj: "..Game.level.collision_world:countItems())
        Log:debug("Anim Obj: "..#Game.level.animated_tiles:get())
        Log:debug("Ent Obj: "..#Game.level.objects:get())
    end
end


function Ingame:success()
    Game:playSound("success", .7)
    Game:transition(function()
        if self.editor_level then Game:switchScene("Editor")
        else self:init(Game.level.id+1) end
    end, 1)
end


function Ingame:fail()
    Game:playSound("fail", .7)
    Game:transition(function()
        if tonumber(Game.level.id) == 12 then self:init(0)
        else self:init() end
    end, .75, {.1, .05, .05})
end


function Ingame:logic(dt)
    Game.level:update(dt)
end


function Ingame:render()
    Game.level:draw()
    Game:print("'TAB' - Switch to editor", 3, 2, {rgba={1, 1, 1, .075}})
    if Game.debug then
        Game:print(("FPS: %d"):format(love.timer.getFPS()), 3, 10, {width = 100})
        local count = collectgarbage("count")
        Game:print(("MEM: %d.%d MB"):format(count/1024, math.fmod(count, 1024)), 3, 20)
        if self.player then
            local vx, vy = self.player.vel.x, self.player.vel.y
            Game:print(("VX: %d   VY: %d"):format(vx, vy), 3, 30, {width = 100})
        end
    end
end


function Ingame:keypressed(key)
    if self.player then self.player:keypressed(key) end
    if key == "r" then self:fail()
    elseif key == "tab" then
        Game:transition(function()
            Game:switchScene("Editor")
        end, 1)
    elseif key == "escape" then
        Game:transition(function() love.event.quit() end, 3)
    end
end


function Ingame:keyreleased(key)
    if self.player then self.player:keyreleased(key) end
end


function Ingame:mousereleased(x, y, button)
    Scene.mousereleased(self, x, y, button)
    if self.player then self.player:mousereleased(x, y, button) end
end

return Ingame
