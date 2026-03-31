-- Copyright © 2020-2026 AKOW Developers
-- Licensed under the terms of the GPL v3. See AUTHORS.txt for details.


return {
    ["clear"] = {
        tooltip = {text="Undo unsaved changes"},
        image = Game.assets.gui.button.clear,
        action = function(element, button)
            if button == 1 then
                Game:transition(function()
                    Game:switchScene("Editor")
                end, .5)
            end
        end
    },
    ["save"] = {
        tooltip = {text="Save the current level"},
        image = Game.assets.gui.button.save,
        action = function(element, button)
            if button == 1 then
                Game.level:save(Game.scene.level_id)
                print("Successfully saved level")
            end
        end
    },
    ["play"] = {
        tooltip = {text="play the current level"},
        image = Game.assets.gui.button.play,
        action = function(element, button)
            if button == 1 then
                Game:transition(function()
                    Game.level:save()
                    Game:switchScene("Ingame", Game.level.id, true)
                end)
            end
        end
    },
    ["quit"] = {
        tooltip = {text="Quit game"},
        image   = Game.assets.gui.button.back,
        action  = function(_, button)
            if button == 1 then
                Game:transition(function() love.event.quit() end, 3)
            end
        end
    },
}