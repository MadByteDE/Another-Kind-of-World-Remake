-- WORKAROUND: Use xwayland instead of wayland to fix some issues with Linux and LÖVE / SDL
local FFI = require("ffi")
FFI.cdef[[ int setenv(const char*, const char*, int); ]]
if FFI.os == "Linux" then FFI.C.setenv("SDL_VIDEO_DRIVER", "x11", 1) end

function love.conf(t)
    -- Setup
    t.title     = 'Another Kind of World'
    t.author    = 'Markus Kothe (Daandruff) - Remade by MadByte'
    t.identity  = t.title

    -- Other settings
    t.modules.joystick  = false
    t.modules.physics   = false
end
