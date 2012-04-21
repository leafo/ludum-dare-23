require "moon"

require "lovekit.all"
reloader = require "lovekit.reloader"

slow_mode = false

g = love.graphics
import timer, keyboard from love

require "guns"
require "player"

class World
  collides: => false

love.load = ->
  viewport = Viewport scale: 4

  w = World!
  p = Player w, 10, 10

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

  love.draw = ->
    viewport\apply!

    p\draw!

    viewport\pop!

