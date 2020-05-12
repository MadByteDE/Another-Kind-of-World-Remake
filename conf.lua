function love.conf(t)
    -- Standard settings
    t.title = 'Another Kind of World'
    t.author = 'Markus Kothe (Daandruff) - Remake by MadByte'

    -- Window
    t.window.width = 768
    t.window.height = 480
    t.window.vsync = true

    -- Other settings
    t.modules.joystick = false
    t.modules.physics = false
end
