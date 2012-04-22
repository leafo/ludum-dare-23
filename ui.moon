
g = love.graphics
import timer, keyboard from love

export *

class TitleScreen
  nil

class GameOver
  nil

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
    g.rectangle "fill", x + @padding, y + @padding, @w - @padding*2, @h - @padding*2
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


