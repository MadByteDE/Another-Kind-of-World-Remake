local Log = { level = 4 }
Log.__index = Log

local sformat = string.format
local types = { "info", "error", "warn", "debug" }


local function message( self, msg, ...)
    local info = debug.getinfo( 3, "Sl" )
    local timestamp = string.match( love.timer.getTime(), "%d+.%d%d%d" )
    local prefix = ("%s [%s%s] "):format(timestamp, info.currentline, info.src)
    local formatted_msg = prefix .. sformat( msg, ... )

    -- Print msg to console
    print( formatted_msg )

    -- Append to buffer string
    self.buffer = self.buffer .. formatted_msg .. "\n"
end


for k, v in ipairs(types) do
    Log[v] = function( self, msg, ... )
        if self.level < k then return end
        message( self, "["..v.."] " .. msg, ... )
    end
end


function Log.create( filename )
    local self = setmetatable( {}, Log )
    self.buffer = ""
    self.file_path = join( "logs", (filename or "latest") .. ".log" )

    -- Create the log directory
    local log_directory = "logs"
    if not love.filesystem.getInfo( log_directory, "directory" ) then
        try( love.filesystem.createDirectory, log_directory )
    end

    -- Remove old log file
    love.filesystem.remove( self.file_path )

    return self
end


function Log:setLevel( v )
    assert( type(v) == "number", "Level must be of type 'number' (is of type '" .. type(v) .. "')" )
    self.level = v or self.level
end


function Log:saveToFile()
    -- Skip if nothing needs to be saved
    if self.buffer == "" then return end

    try( love.filesystem.append, self.file_path, self.buffer )

    -- Reset buffer
    self.buffer = ""
end


function Log:message( msg, ... )
    message( self, msg, ... )
end

return Log
