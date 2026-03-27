return {
    ["glitter"] = {
        images={Game.assets.particle.glitter},
        width=8, height=1, offset={x=0, y=7},
        collide=true, bounciness=.3, damp={x=2, y=0},
        lifetime=1.5, range={x={-60, 60}, y={-50, -80}},
        filter=function(self, other)
            -- TODO: Simplify cross behaviour (if entity then cross!)
            if other.type == "player" then return "cross"
            elseif other.type == "particle" then return "cross"
            elseif other.type == "exit" then return "cross"
            elseif other.type == "bomb" then return "cross"
            elseif other.type == "bug" then return "cross"
            else return "bounce" end
        end
    },

    ["blood"] = {
        images={Game.assets.particle.blood},
        width=4, height=4, offset={x=2, y=2},
        lifetime=.5, wrap=false, range={x={-25, 25}, y={-40, -80}},
        filter=function(self, other)
            if not other.solid then return "cross"
            else return end
        end,
    },

    ["explosion"] = {
        images={Game.assets.particle.smoke, Game.assets.particle.fire},
        width=4, height=4, offset={x=2, y=2},
        lifetime=.75, wrap=false, range={x={-40, 40}, y={-50, -110}},
    },

    ["dust"] = {
        images={Game.assets.particle.dust},
        collide=true, bounciness=.5, damp={x=2, y=0},
        width=1, height=1, lifetime=1, wrap=false, range={x={-35, 35}, y={-40, -60}},
        filter=function(self, other)
            -- TODO: Simplify cross behaviour (if entity then cross!)
            if other.type == "player" then return "cross"
            elseif other.type == "particle" then return "cross"
            elseif other.type == "exit" then return "cross"
            elseif other.type == "bomb" then return "cross"
            elseif other.type == "bug" then return "cross"
            else return "bounce" end
        end
    },
}