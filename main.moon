require "moon"

require "lovekit.all"
reloader = require "lovekit.reloader"

slow_mode = false

g = love.graphics
import timer, keyboard from love

require "guns"
require "player"
require "background"
require "lovekit.screen_snap"

class World
  collides: => false

snapper = nil

love.load = ->
  viewport = Viewport scale: 4

  w = World!
  p = Player w, 50, 100
  b = Background viewport

  love.keypressed = (key, code) ->
    switch key
      when "escape" then os.exit!
      when "x" -- cool
        if snapper
          slow_mode = false
          snapper = nil
        else
          slow_mode = true
          snapper = ScreenSnap!
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

    snapper\tick! if snapper

