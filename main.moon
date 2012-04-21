require "moon"

require "lovekit.all"
reloader = require "lovekit.reloader"

slow_mode = false

g = love.graphics
import timer, keyboard from love

export n = (thing) -> thing.__name or thing.__class.__name

require "guns"
require "player"
require "background"
require "effects"
require "enemy"

require "lovekit.screen_snap"

class World
  new: (@viewport) =>
    @bg = Background @viewport

  draw: => @bg\draw!
  update: (dt) => @bg\update dt

  collides: (thing) =>
    @bg\collides thing

snapper = nil

love.load = ->
  viewport = Viewport scale: 4

  w = World viewport
  p = Player w, 50, 100
  e = RandomEnemySpanwer w

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
    w\update dt
    e\update dt

  love.draw = ->
    viewport\apply!

    w\draw!
    p\draw!
    e\draw!

    g.print tostring(timer.getFPS!), 2, 2

    viewport\pop!

    snapper\tick! if snapper

