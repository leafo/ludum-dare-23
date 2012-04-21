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
require "particle"

require "lovekit.screen_snap"

class EffectViewport extends Viewport
  new: (...) =>
    @effects = EffectList!
    super ...

  shake: =>
    @effects\add effects.Shake 0.4

  update: (dt) => @effects\update dt

  apply: =>
    super!
    e\before @obj for e in *@effects

  pop: =>
    e\after @obj for e in *@effects
    super!

    s = @screen.scale
    g.scale 1/s, 1/s


class World
  new: (@viewport) =>
    @bg = Background @viewport
    @enemies = ReuseList!
    @spawner = RandomEnemySpanwer self, @enemies

  draw: =>
    @bg\draw!
    @enemies\draw!

    Emitter\draw_all!

  update: (dt) =>
    @spawner\update dt
    @enemies\update dt
    @bg\update dt

  collides: (thing) =>
    @bg\collides thing

snapper = nil

love.load = ->
  viewport = EffectViewport scale: 4

  w = World viewport
  p = Player w, 50, 100

  emitter = Emitter w, 10, 40

  font_image = imgfy"img/font.png"

  font = g.newImageFont font_image.tex, " 1234567890"
  g.setFont font

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

    viewport\update dt
    p\update dt
    w\update dt
    emitter\update dt

  love.draw = ->
    viewport\apply!

    w\draw!
    p\draw!

    g.print tostring(timer.getFPS!), 2, 2
    viewport\pop!

    snapper\tick! if snapper

