
local fonts     = {}
local sounds    = {
  ["music"]   = la.newSource("assets/sounds/music.ogg", "stream"),
  ["boom"]    = la.newSource("assets/sounds/boom.ogg", "static"),
  ["toss"]    = la.newSource("assets/sounds/toss.ogg", "static"),
  ["jump"]    = la.newSource("assets/sounds/jump.ogg", "static"),
  ["splat"]   = la.newSource("assets/sounds/splat.ogg", "static"),
  ["success"] = la.newSource("assets/sounds/success.ogg", "static"),
  ["fail"]    = la.newSource("assets/sounds/fail.ogg", "static"),
}

local playSound = function(name, vol, loop)
  local source = sounds[name]
  if vol then source:setVolume(vol) end
  if source:isPlaying() then source:stop() end
  source:play()
  if loop ~= nil then source:setLooping(loop) end
end

local cloneSound = function(name)
  return sounds[name]:clone()
end

local images = {
  ["spritesheet"] = lg.newImage("assets/spritesheet.png"),
  ["dirtcover"]   = lg.newImage("assets/dirtcover.png"),
}

local getImage = function(name)
  return images[name]
end

local drawDirtCover = function(scale)
  if scale then
    lg.push()
    lg.scale(scale, scale)
  end
  love.graphics.setColor(1, 1, 1, .45)
  love.graphics.draw(getImage("dirtcover"))
  love.graphics.setColor(1, 1, 1, 1)
  if scale then lg.pop() end
end

local tw      = 8
local iw, ih  = getImage("spritesheet"):getDimensions()
local grids   = {
  ["sprite"]        = Anim8.newGrid(tw, tw, iw, ih),
  ["tile"]          = Anim8.newGrid(tw, tw, iw, ih, 56, 0),
  ["animatedTile"]  = Anim8.newGrid(tw, tw, iw, ih, 56, 24),
  ["button"]        = Anim8.newGrid(10, 9, iw, ih, 32, 32), }

local getQuad = function(grid, data)
  local frames, row = unpack(data)
  if type(frames) == "number" then frames = frames.."-"..frames end
  local quads = grids[grid](frames, row)
  if #quads > 1 then return quads
  else return quads[1] end
end

local tiles   = {
  { name        = "back",
    type        = "tile",
    pixelColor  = {0, 0, 0},
    quad        = getQuad("tile", {6, 1}) },
  { name        = "wall",
    type        = "tile",
    pixelColor  = {1, 0, 0},
    quad        = getQuad("tile", {1, 1}),
    collides    = true,
    isSolid     = true, },
  { name        = "top",
    type        = "tile",
    pixelColor  = {0, 1, 0},
    quad        = getQuad("tile", {4, 1}),
    collides    = true,
    isSolid     = true, },
  { name        = "under",
    type        = "tile",
    pixelColor  = {1, 1, 0},
    quad        = getQuad("tile", {3, 1}),
    collides    = true,
    isSolid     = true, },
  { name        = "pillar",
    type        = "tile",
    pixelColor  = {128/255, 0, 128/255},
    quad        = getQuad("tile", {2, 1}), },
  { name        = "drain",
    type        = "animatedTile",
    pixelColor  = {128/255, 0, 0},
    quad        = getQuad("tile", {1, 2}),
    collides    = true,
    isSolid     = true, },
  { name        = "grass",
    type        = "animatedTile",
    pixelColor  = {0, 1, 1},
    quad        = getQuad("tile", {3, 2}),
    randomFrame = true, },
  { name        = "water",
    type        = "animatedTile",
    pixelColor  = {0, 0, 128/255},
    quad        = getQuad("tile", {2, 2}), },
  { name        = "exit",
    type        = "entity",
    pixelColor  = {1, 1, 1},
    quad        = getQuad("tile", {5, 1}), },
  { name        = "player",
    type        = "entity",
    pixelColor  = {1, 0, 1},
    quad        = getQuad("tile", {4, 2}), },
  { name        = "bug",
    type        = "entity",
    pixelColor  = {0, 0, 1},
    quad        = getQuad("tile", {5, 2}), },
}

local getTile = function(name)
  for i=1, #tiles do
    local tile = tiles[i]
    if tile.name == string.lower(name) then return tile end
  end
end

local buttons = {
  ["clear"] = getQuad("button", {1, 1}),
  ["back"]  = getQuad("button", {2, 1}),
  ["play"]  = getQuad("button", {1, 2}),
  ["save"]  = getQuad("button", {2, 2}),
}

local getButton = function(name)
  return buttons[name]
end

local elements = {
  ["tilepanel"] = lg.newQuad(0, 32, 32, 48, iw, ih),
}

local getElement = function(name)
  return elements[name]
end

local newAnimation = function(grid, data)
  local frames, row, duration, onLoop = unpack(data)
  local anim = Anim8.newAnimation(grids[grid](frames, row), duration, onLoop)
  return anim
end

local animations = {
  ["player"] = newAnimation("sprite", {'1-6', 1, .1}),
  ["bomb"]   = newAnimation("sprite", {'4-7', 3, .1}),
  ["bug"]    = newAnimation("sprite", {'1-6', 2, .15}),
  ["grass"]  = newAnimation("animatedTile", {'1-4', 3, .2}),
  ["drain"]  = newAnimation("animatedTile", {'1-8', 1, .05}),
  ["water"]  = newAnimation("animatedTile", {'1-8', 2, .05}),
}

local getAnimation = function(name)
  return animations[name]:clone()
end

return {
  tilesize      = tw,
  spritesheet   = images["spritesheet"],
  getQuad       = getQuad,
  newAnimation  = newAnimation,
  getAnimation  = getAnimation,
  getButton     = getButton,
  getElement    = getElement,
  tiles         = tiles,
  getTile       = getTile,
  getAnimation  = getAnimation,
  playSound     = playSound,
  cloneSound    = cloneSound,
  getImage      = getImage,
  drawDirtCover = drawDirtCover,
}
