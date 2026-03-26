return {
    ["glitter"] = {
        images={Game.assets.particle.glitter},
        dim={w=8, h=1}, trans={r=0, sx=1, sy=1, ox=0, oy=7},
        collide=true, bounciness=.3, damp={x=2, y=0},
        lifetime=1.5, range={x={-60, 60}, y={-50, -80}},
        filter=function(self, other)
            if other.type == "player" then return "cross"
            elseif other.type == "particle" then return "cross"
            elseif other.type == "exit" then return "cross"
            else return "bounce" end
        end
    },

    ["blood"] = {
        images={Game.assets.particle.blood},
        dim={w=4, h=4}, trans={r=0, sx=1, sy=1, ox=2, oy=2},
        lifetime=.5, wrap=false, range={x={-25, 25}, y={-40, -80}},
        filter=function(self, other)
            if not other.solid then return "cross"
            else return end
        end,
    },

    ["explosion"] = {
        images={Game.assets.particle.smoke, Game.assets.particle.fire},
        dim={w=4, h=4}, trans={r=0, sx=1, sy=1, ox=2, oy=2},
        lifetime=.75, wrap=false, range={x={-40, 40}, y={-50, -110}},
    },
}