-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Level = require("src.level")
local Scene = require("src.scenes.scene")
local Ingame = Class()
Ingame:include(Scene)


function Ingame:init(id, isEditorLevel)
    Scene.init(self)
    self.name = "Ingame"
    self.debugMode = false
    self.currentId = id or self.currentId or 0
    self.level = Level(self.currentId)
    self.isEditorLevel = isEditorLevel or false
    self.player = self.level:getObject("player")[1]

    if arg[2] == "debug" then
        Game.log:debug("Col Obj: "..self.level.collisionWorld:countItems())
        Game.log:debug("Anim Obj: "..#self.level.animatedTiles:get())
        Game.log:debug("Ent Obj: "..#self.level.objects:get())
    end
end


function Ingame:success()
    Game.assets.playSound("success", .7)
    Game.screen:transition(function()
        if self.isEditorLevel then Game:switchScene("Ingame")
        else self:init(tonumber(self.level.id)+1) end
    end, 1)
end


function Ingame:fail()
    Game.assets.playSound("fail", .7)
    Game.screen:transition(function()
        if tonumber(self.level.id) == 12 then self:init(0)
        else self:init() end
    end, .75, {.1, .05, .05})
end


function Ingame:logic(dt)
    self.level:update(dt)
end


function Ingame:render()
    self.level:draw()
    Game.assets.print("'TAB' - Switch to editor", 3, 2, {rgba={1, 1, 1, .075}})
    if arg[2] == "debug" then
        local vx, vy = self.player.vel.x, self.player.vel.y
        Game.assets.print(("VX: %d   VY: %d"):format(vx, vy), 3, 10, {width = 100})
        Game.assets.print(("FPS: %d"):format(love.timer.getFPS()), 3, 20, {width = 100})
        local count = collectgarbage("count")
        Game.assets.print(("MEM: %d.%d MB"):format(count/1024, math.fmod(count, 1024)), 3, 30)
    end
end


function Ingame:keypressed(key)
    if self.player then self.player:keypressed(key) end
    if key == "r" then self:fail()
    elseif key == "tab" then
        Game.screen:transition(function()
        Game:switchScene("Editor")
            if not self.isEditorLevel then
                Game.current_scene:init(self.level.id)
            end
        end, 1)
    elseif key == "escape" then
        Game.screen:transition(function() love.event.quit() end, 3)
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
