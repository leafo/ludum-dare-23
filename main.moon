require "moon"

require "lovekit.all"
reloader = require "lovekit.reloader"

slow_mode = false

g = love.graphics
import timer, keyboard from love

export n = (thing) ->
  if type(thing) == "table"
    thing.__name or (thing.__class and thing.__class.__name) or tostring thing
  else
    tostring thing

require "particle"
require "guns"
require "player"
require "background"
require "effects"
require "enemy"
require "ui"

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
    @spawner = EnemyWave self, @enemies

  draw: =>
    @bg\draw!
    @enemies\draw!
    Emitter\draw_all!

  update: (dt) =>
    Emitter\update_all dt, self

    @spawner\update dt
    @enemies\update dt
    @bg\update dt

  collides: (thing) =>
    @bg\collides thing

class Game
  new: =>
    @viewport = EffectViewport scale: 4

    @world = World @viewport
    @player = Player @world, 50, 100
    @hud = Hud @viewport, @player

  update: (dt) =>
    @viewport\update dt
    @player\update dt
    @world\update dt

    @hud\update dt

  draw: =>
    @viewport\apply!

    @world\draw!
    @player\draw!

    g.print tostring(timer.getFPS!), 2, 12

    @hud\draw!
    @viewport\pop!

snapper = nil

love.load = ->
  export game = Game!

  font_image = imgfy"img/font.png"

  font = g.newImageFont font_image.tex, " 1234567890"
  g.setFont font

  love.mousepressed = (x,y, button) ->
    x, y = game.viewport\unproject x, y
    -- emitters.PourSmoke\add w, x, y

  love.keypressed = (key, code) ->
    switch key
      when "escape" then os.exit!
      when "d"
        game.player\die!
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
    reloader\update!
    dt /= 3 if slow_mode
    game\update dt

  love.draw = ->
    snapper\tick! if snapper
    game\draw!

