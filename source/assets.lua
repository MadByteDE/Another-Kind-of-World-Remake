

local la = love.audio
local lg = love.graphics

-- Fonts
local font = {}


-- Audio
local audio = {}
audio["music"]   = la.newSource("assets/sounds/gamemusic.ogg", "stream")
audio["boom"]    = la.newSource("assets/sounds/boom.ogg", "static")
audio["toss"]    = la.newSource("assets/sounds/toss.ogg", "static")
audio["jump"]    = la.newSource("assets/sounds/jump.ogg", "static")
audio["splat"]   = la.newSource("assets/sounds/splat.ogg", "static")
audio["success"] = la.newSource("assets/sounds/success.ogg", "static")
audio["fail"]    = la.newSource("assets/sounds/fail.ogg", "static")

audio.play = function(name, vol, loop)
  local source = audio[name]
  if vol then source:setVolume(vol) end
  if source:isPlaying() then source:stop() end
  source:play()
  if loop ~= nil then source:setLooping(loop) end
end
audio.clone = function(name)
  return audio[name]:clone()
end


-- Images
local image =  {
  ["dirtcover"] = lg.newImage("assets/dirtcover.png")
}


-- Sprites
local Anim8     = require("source.lib.anim8")
local sprite    = {image = lg.newImage("assets/spritesheet.png")}
local iw, ih    = sprite.image:getDimensions()
local tw        = 8
sprite.grid     = Anim8.newGrid(tw, tw, iw, ih)
sprite.newQuad  = function(frame, row)
  return sprite.grid(frame.."-"..frame, row)[1]
end
sprite.newAnimation = function(frames, row, durations, onLoop)
  local anim = Anim8.newAnimation(sprite.grid(frames, row), durations, onLoop):clone()
  return anim
end


-- Tileset
local tileset = {image = lg.newImage("assets/tileset.png")}
local iw, ih  = tileset.image:getDimensions()

tileset.tiles   = {
  ["wall"] = {
    pixelColor = {1, 0, 0},
    quad = lg.newQuad(tw*0, 0, tw, tw, iw, ih),
    collides = true,
    isSolid = true},
  ["top"] = {
    pixelColor = {0, 1, 0},
    quad = lg.newQuad(tw*3, 0, tw, tw, iw, ih),
    collides = true,
    isSolid = true},
  ["back"] = {
    pixelColor = {0, 0, 0},
    quad = lg.newQuad(tw*6, 0, tw, tw, iw, ih)},
  ["grass"] = {
    pixelColor = {0, 1, 1},
    quad = lg.newQuad(tw*5, 0, tw, tw, iw, ih)},
  ["under"] = {
    pixelColor = {1, 1, 0},
    quad = lg.newQuad(tw*2, 0, tw, tw, iw, ih),
    collides = true,
    isSolid = true},
  ["pillar"] = {
    pixelColor = {128/255, 0, 128/255},
    quad = lg.newQuad(tw*1, 0, tw, tw, iw, ih)},
  ["exit"] = {
    pixelColor = {1, 1, 1},
    quad = lg.newQuad(tw*6, 0, tw, tw, iw, ih)},
  ["player"] = {
    pixelColor = {1, 0, 1},
    quad = lg.newQuad(tw*6, 0, tw, tw, iw, ih)},
  ["bug"] = {
    pixelColor = {0, 0, 1},
    quad = lg.newQuad(tw*6, 0, tw, tw, iw, ih)},
}


return {
  font          = font,
  audio         = audio,
  tileset       = tileset,
  image         = image,
  sprite        = sprite,
  newQuad       = sprite.newQuad,
  newAnimation  = sprite.newAnimation,
  getTilesize   = function() return tw end,
  getTile       = tileset.getTile,
}
