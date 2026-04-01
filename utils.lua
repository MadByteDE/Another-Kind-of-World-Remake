function try(funct, ...)
    local status, result = pcall(funct, ...)
    if status then return result
    else error(result) end
end


local types = {"nil", "number", "string", "function", "boolean", "userdata", "table", "thread"}
function checkType(v, name)
    assert(types[name] == nil, ("Invalid argument: '%s' is not a valid data type"):format(name))
    assert(type(v) == name, ("Invalid type '%s': Value must be of type '%s'"):format(type(v), name))
end


function join(...)
    return table.concat({...}, "/"):gsub("//+", "/")
end


function random_range(value, range)
    return value + math.random(-range, range)
end


function split(path)
    return path:match("(.*/)(.*)")
end


function clamp(val, min, max)
    if not val then return end
    return math.min(math.max(val, min), max)
end


function round(num, idp)
	local mult = 10^(idp or 0)
    if num >= 0 then
		return math.floor(num * mult + 0.5) / mult
    else
		return math.ceil(num * mult - 0.5) / mult
	end
end


function getAngle(x1, x2, y1, y2)
    return math.atan2(y2-y1, x2-x1)
end


function getDistance(a, b)
    return math.sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2)
end


function circleCollision(a, b)
    local r1 = a.radius or a:getRadius()
    local r2 = b.radius or b:getRadius()
	local dx = b.x - a.x
	local dy = b.y - a.y
	return dx^2 + dy^2 < (r1 + r2)^2
end


function rectCollision(a, b)
    return a.x + a.width > b.x and a.x < b.x + b.width and
    a.y + a.height > b.y and a.y < b.y + b.height
end


function serialize(T, indent)
    if not indent then indent = 0 end
    local str = "{\r\n"
    indent = indent + 2
    for k, v in pairs(T) do
        str = str .. string.rep(" ", indent)
        -- Key
        if (type(k) == "number") then str = str .. "[" .. k .. "] = "
        elseif (type(k) == "string") then str = str  .. k ..  " = "
        end
        -- Value
        if (type(v) == "number") then str = str .. v .. ",\r\n"
        elseif (type(v) == "string") then str = str .. "\"" .. v .. "\",\r\n"
        elseif (type(v) == "table") then str = str .. serialize(v, indent + 2) .. ",\r\n"
        elseif (type(v) == "boolean") then str = str .. "" .. tostring(v) .. ",\r\n"
        else str = str .. "\"" .. tostring(v) .. "\",\r\n"
        end
    end
    str = str .. string.rep(" ", indent-2) .. "}"
    return str
end


local charset = '0123456789ABCDEFGHIYKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
function newUID()
    local id = ""
    for i = 1, 8 do
        local n = math.random(1, #charset)
        id = id .. string.sub(charset, n, n)
    end
    return id
end