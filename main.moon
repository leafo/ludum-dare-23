require "moon"

require "lovekit.all"
-- reloader = require "lovekit.reloader"

g = love.graphics

class World
  collides: => false

class Player extends Entity
  speed: 100

  update: (dt) =>
    @velocity\update unpack movement_vector @speed
    super dt

love.load = ->
  viewport = Viewport scale: 4

  w = World!
  p = Player w, 10, 10

  love.keypressed = (key, code) ->
    switch key
      when "escape" then os.exit!

  love.update = (dt) ->
    p\update dt

  love.draw = ->
    viewport\apply!

    p\draw!

    g.print "hello world", 10, 10
    viewport\pop!


