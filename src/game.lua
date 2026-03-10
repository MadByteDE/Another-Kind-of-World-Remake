-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Log = require("src.lib.log")
local Game = {}


function Game:load()
    self.log = Log.create("latest")
    self.assets = require("src.assets")
    self.screen = require("src.screen")
    self.scenes = {
        Ingame  = require("src.scenes.ingame"),
        Editor  = require("src.scenes.editor")
    }
    self.current_scene = {
        init=_NULL_,
        update=_NULL_,
        getMouse=_NULL_,
        draw=_NULL_,
        keypressed=_NULL_,
        mousepressed=_NULL_,
        mousereleased=_NULL_
    }

    self.log:message("Logs will be saved in: %s", join( love.filesystem.getSaveDirectory(), "logs" ))
    love.graphics.setFont(Game.assets.fonts["normal"])

    self.screen:init({width = 256, height = 160, scale = 4})
    self.screen:transition(function()
        self:switchScene("Ingame")
        self.current_scene:init()
        self.current_scene:getMouse():setPosition(Game.screen.width/2, Game.screen.height/2)
    end, 2)
    self.assets.playSound("music", .275, true)
end


function Game:switchScene(name)
    if not self.scenes[name] then Game.log:error("Scene '%s' does not exist", name); return end
    self.current_scene = self.scenes[name]
end


function Game:update(dt)
    self.screen:update(dt)
    self.current_scene:update(dt)
end


function Game:draw()
    self.screen:push()
    self.current_scene:draw()
    self.screen:pop()
    self.assets.drawDirtCover(Game.screen.scale)
end


function Game:keypressed(key) self.current_scene:keypressed(key) end

function Game:keyreleased(key) self.current_scene:keyreleased(key) end

function Game:mousepressed(x, y, button) self.current_scene:mousepressed(x, y, button) end

function Game:mousereleased(x, y, button) self.current_scene:mousereleased(x, y, button) end

function Game:textinput(...)
    self.current_scene:textinput(...)
end

return Game