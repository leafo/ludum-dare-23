
g = love.graphics

export *

class Background
  height: 200

  new: (@viewport) =>
    @tile = imgfy"img/tile.png"
    @tile\set_wrap "repeat", "repeat"

    @elapsed = 0

    @effect = g.newPixelEffect [[
      extern number time;
      extern bool flip;

      vec4 effect(vec4 color, sampler2D tex, vec2 st, vec2 pixel_coords) {
        float x = st.x;
        if (flip) x = 1 - x;

        float y = st.y - 0.5; // center coordinate system
        y /= (x * 0.5 + 0.5);
        y += 0.5;

        return texture2D(tex, vec2(x, y - time));
      }
    ]]

  update: (dt) =>
    @elapsed += dt
    @effect\send "time", @elapsed

  draw: =>
    g.setPixelEffect @effect

    sy = @height / @tile\width!

    -- left
    @effect\send "flip", 1
    @tile\draw 0, -25, 0, 1, sy

    -- right
    @effect\send "flip", 0
    @tile\draw @viewport.w - @tile\width!, -25, 0, 1, sy

    g.setPixelEffect!

