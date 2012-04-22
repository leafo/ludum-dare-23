
g = love.graphics
import timer, keyboard from love
import insert, remove from table

export *

-- ugh
fade_effect = (prev, current, t) ->
  t = smoothstep 0, 1, t

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

  pop: =>
    @blend_effect = nil

    os.exit! if #stack == 0
    remove @stack

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
    dispatch\push_with_effect Game!, 1, fade_effect

  draw: =>
    @viewport\apply!
    @img\draw 0, 0

class GameOver
  high_scores: {
    1000, 10000, 50000, 100000, 250000, 500000, 1000000
  }

  new: =>
    @sort_scores!

  sort_scores: =>
    table.sort @high_scores

  add_score: (score) =>
    table.insert @high_scores, scores
    @sort_scores!

  draw_high_scores: =>

class Pause
  nil

class HorizBar
  color: { 255, 128, 128, 128 }
  padding: 1

  new: (@w, @h, @value=0.5)=>

  draw: (x, y) =>
    g.push!
    g.setLineWidth 0.6
    g.rectangle "line", x, y, @w, @h

    g.setColor @color
    w = @value * (@w - @padding*2)

    g.rectangle "fill", x + @padding, y + @padding, w, @h - @padding*2
    g.pop!

    g.setColor 255,255,255,255

class Hud
  padding: 3
  score: 0
  display_score: 0

  new: (@viewport, @player) =>
    @health_bar = HorizBar 50, 6

  draw: =>
    @health_bar\draw 2, 2
    g.print tostring(math.floor(@display_score)), 54, 1

  update: (dt) =>
    if @display_score < @score
      @display_score += dt * math.max 200, @score - @display_score
      @display_score = math.min @display_score, @score

    @health_bar.value = @player.health / @player.max_health

