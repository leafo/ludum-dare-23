require "lovekit.all"

export watch_class = ->
-- reloader = require "lovekit.reloader"

slow_mode = false

g = love.graphics
import timer, keyboard, audio from love

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
require "powerups"
require "enemy"
require "ui"
require "audio"

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

    @enemy_bullets = ReuseList!

    @spawner = EnemyWave self, @enemies
    @powerups = ReuseList!

  draw: =>
    @bg\draw!
    @enemies\draw!
    @powerups\draw!
    @enemy_bullets\draw!
    Emitter\draw_all!

  update: (dt) =>
    Emitter\update_all dt, self

    @spawner\update dt
    @enemies\update dt
    @powerups\update dt
    @enemy_bullets\update dt, self
    @bg\update dt

  collides: (thing) =>
    @bg\collides thing

export class Game
  new: =>
    @start_time = timer.getTime!
    @viewport = EffectViewport scale: 4

    @world = World @viewport
    @player = Player @world, 50, 100
    @hud = Hud @viewport, @player

  goto_gameover: =>
    game_over = GameOver @hud.score, timer.getTime! - @start_time
    dispatch\push_with_effect game_over, 2.0, fade_effect

  update: (dt) =>
    @viewport\update dt
    @player\update dt
    @world\update dt

    @hud\update dt

    if @player.health <= 0 and #@player.effects == 0
      @goto_gameover!

  draw: =>
    @viewport\apply!

    @world\draw!
    @player\draw!

    g.print tostring(timer.getFPS!), 2, 12

    @hud\draw!
    @viewport\pop!

snapper = nil

love.load = ->
  export dispatch = Dispatch TitleScreen!
  export sfx = Audio!
  -- export game = Game!

  music = audio.newSource "audio/theme.ogg"
  music\setLooping true
  music\play!

  sfx\preload {
    "die_enemy"
    "hit_enemy"
    "powerup"
    "shoot"
    "shoot_2"
    "charge"
    "start_game"
    "die_player"
    "hit_wall"
    "hit_player"
  }

  font_image = imgfy"img/font.png"

  font = g.newImageFont font_image.tex, " 1234567890"
  g.setFont font

  love.mousepressed = (x,y, button) ->
    if game
      x, y = game.viewport\unproject x, y
      -- game.world.powerups\add GunPowerup, x, y
      -- game.player\die!
      -- game.world.bg\feed_energy 3
      -- game.world.powerups\add HealthPowerup, x, y
      -- emitters.PourSmoke\add w, x, y

  love.keypressed = (key, code) ->
    return if dispatch\send_key key, code

    switch key
      when "escape" then os.exit!
      -- when "d"
      --   game.player\die! if game
      -- when "XX" -- cool
      --   if snapper
      --     slow_mode = false
      --     snapper = nil
      --   else
      --     slow_mode = true
      --     snapper = ScreenSnap!
      -- when "s"
      --   slow_mode = not slow_mode
      --   print "slow mode:", slow_mode

  love.update = (dt) ->
    -- reloader\update!
    dt /= 3 if slow_mode
    dispatch\update dt

  love.draw = ->
    snapper\tick! if snapper
    dispatch\draw!

