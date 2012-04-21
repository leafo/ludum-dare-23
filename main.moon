require "moon"

require "lovekit.all"
reloader = require "lovekit.reloader"

slow_mode = false

g = love.graphics
import timer, keyboard from love

require "guns"
require "player"
require "background"

class World
  collides: => false

love.load = ->
  viewport = Viewport scale: 4

  effect = g.newPixelEffect [[
    extern number time;

    vec4 effect(vec4 color, sampler2D tex, vec2 st, vec2 pixel_coords) {
      float y = st.y - 0.5; // center coordinate system
      y /= (st.x * 0.5 + 0.5);
      y += 0.5;
      return texture2D(tex, vec2(1 - st.x, y - time));
    }
  ]]

  w = World!
  p = Player w, 50, 100
  b = Background viewport

  love.keypressed = (key, code) ->
    switch key
      when "escape" then os.exit!
      when "s"
        slow_mode = not slow_mode
        print "slow mode:", slow_mode

  love.update = (dt) ->
    dt /= 3 if slow_mode

    reloader\update!
    p\update dt
    b\update dt

  love.draw = ->
    viewport\apply!

    b\draw!
    p\draw!

    viewport\pop!

