-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.

local Scene = Class()


function Scene:init()end
function Scene:leave()end


function Scene:update(dt)
    self:logic(dt)
end


function Scene:draw()
    self:render()
end

function Scene:logic(dt) end
function Scene:render() end
function Scene:mousepressed(...) end
function Scene:mousereleased(...) end
function Scene:wheelmoved(...) end
function Scene:keypressed(...)end
function Scene:keyreleased(...)end
function Scene:textinput(...) end

return Scene
