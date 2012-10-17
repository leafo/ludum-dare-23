
g = love.graphics
import timer, keyboard from love
import insert, remove from table

export *

-- ugh
fade_effect = (prev, current, t) ->
  -- t = smoothstep 0, 1, t

  if t < 0.5
    prev\draw!

    g.setColor 0,0,0, 255 * t * 2
    g.rectangle "fill", 0,0, g.getWidth!, g.getHeight!
    g.setColor 255,255,255,255
  else
    current\draw!

    g.setColor 0,0,0, 255 * (1 - t) * 2
    g.rectangle "fill", 0,0, g.getWidth!, g.getHeight!
    g.setColor 255,255,255,255

class Dispatch
  new: (initial) =>
    @stack = { initial }

  send: (event, ...) =>
    current = @top!
    current[event] current, ... if current and current[event]

  send_key: (...) => @send "on_key", ...

  top: => @stack[#@stack]
  parent: => @stack[#@stack - 1]

  push: (state) =>
    @blend_effect = nil
    insert @stack, state

  push_with_effect: (state, time, efx) =>
    @elapsed = 0
    @effect_time = time

    prev = @top!
    @blend_effect = (t) => efx prev, state, t

    insert @stack, state

  pop: (n=1) =>
    @blend_effect = nil
    while n > 0
      os.exit! if #@stack == 0
      remove @stack
      n -= 1

  draw: =>
    if @blend_effect
      @blend_effect @elapsed / @effect_time
    else
      @send "draw"

  update: (dt) =>
    if @blend_effect
      @elapsed += dt
      @blend_effect = nil if @elapsed > @effect_time

    @send "update", dt

class TitleScreen
  new: =>
    @viewport = Viewport scale: 4
    @img = imgfy"img/title.png"

  on_key: (key) =>
    switch key
      when "escape" then os.exit!
      when "return" then @start_game!

  start_game: =>
    sfx\play "start_game"
    export game = Game! -- :)
    dispatch\push_with_effect game, 0.3, fade_effect

  draw: =>
    @viewport\apply!
    @img\draw 0, 0
    @viewport\pop!

class GameOver
  watch_class self

  new: (@score, @time) =>
    @viewport = Viewport scale: 4
    @img = imgfy"img/gameover.png"
    @time = math.floor @time

  on_key: (key) =>
    next_keys = { k, true for k in *{"return", "x", "c", "escape"} }

    if next_keys[key]
      dispatch\pop 2

  draw: =>
    @viewport\apply!
    @img\draw 0, 0

    g.print tostring(@score), 45, 43
    g.print tostring(@time), 45, 56
    @viewport\pop!

class Pause
  nil

class HorizBar
  color: { 255, 128, 128, 128 }
  border: true
  padding: 1

  new: (@w, @h, @value=0.5)=>

  draw: (x, y) =>
    g.push!

    if @border
      g.setLineWidth 0.6
      g.rectangle "line", x, y, @w, @h

      g.setColor @color
      w = @value * (@w - @padding*2)

      g.rectangle "fill", x + @padding, y + @padding, w, @h - @padding*2
    else
      g.setColor @color
      w = @value * @w
      g.rectangle "fill", x, y, w, @h

    g.pop!
    g.setColor 255,255,255,255

class Hud
  padding: 3
  score: 0
  display_score: 0

  new: (@viewport, @player) =>
    @health_bar = HorizBar 50, 6
    @charge_bar = with HorizBar 96, 1
      .value = 0.0
      .color = { 226, 44, 240, 128 }
      .border = false
      .padding = 0

  draw: =>
    @health_bar\draw 2, 2
    g.print tostring(math.floor(@display_score)), 54, 1

    @charge_bar\draw 2, @viewport.h - 2 - @charge_bar.h

  update: (dt) =>
    if @display_score < @score
      @display_score += dt * math.max 200, @score - @display_score
      @display_score = math.min @display_score, @score

    @health_bar.value = @player.health / @player.max_health

    beta_gun = @player.guns.beta
    @charge_bar.value = math.sqrt beta_gun.time / beta_gun.charge_time


