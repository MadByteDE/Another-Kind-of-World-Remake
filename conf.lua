function love.conf(t)
    -- Setup
    t.title     = 'Another Kind of World'
    t.author    = 'Markus Kothe (Daandruff) - Remade by MadByte'
    t.identity  = t.title

    -- Window
    t.window.width  = 768
    t.window.height = 480
    t.window.vsync  = true
    t.window.borderless = true

    -- Other settings
    t.modules.joystick  = false
    t.modules.physics   = false
end
