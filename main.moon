
require "lovekit.all"
-- reloader = require "lovekit.reloader"

g = love.graphics

love.load = ->
  viewport = Viewport scale: 4

  love.draw = ->
    viewport\apply!
    g.print "hello world", 10, 10
    viewport\pop!


