
g = love.graphics
import mouse from love

export *

class Background
  height: 200
  padding: 10

  new: (@viewport) =>
    @tile = imgfy"img/tile.png"
    @tile\set_wrap "repeat", "repeat"

    @span = 1

    @elapsed = 0

    @effect = g.newPixelEffect [[
      extern number time;
      extern bool persp;

      vec4 effect(vec4 color, sampler2D tex, vec2 st, vec2 pixel_coords) {
        float x = 1 - st.x;
        float y = st.y - 0.5; // center coordinate system
        if (persp) y /= (x * 0.5 + 0.5);
        y += 0.5;

        return texture2D(tex, vec2(x, y*4 - time)) * vec4(x); // vec4(vec3(x), 1);
      }
    ]]

  update: (dt) =>
    @elapsed += dt
    @effect\send "time", @elapsed

    x = @viewport\unproject mouse.getPosition!
    @padding = 50 * x / @viewport.w

  draw: =>
    g.setPixelEffect @effect

    sy = @height / @tile\width!
    sx = (1 - @padding / 50) * 0.8

    @effect\send "persp", 1



    -- left
    @tile\draw @padding, -25, 0, sx, sy
    -- right
    @tile\draw @viewport.w - @padding, -25, 0, -sx, sy

    -- top left
    @effect\send "persp", 0
    @tile\draw @padding, -25, 0, -1, sy
    -- top right
    @tile\draw @viewport.w - @padding, -25, 0, 1, sy

    g.setPixelEffect!

