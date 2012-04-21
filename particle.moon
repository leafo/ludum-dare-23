
import graphics, timer, keyboard from love

export *

class Particle
  size: 1
  life: 1
  color: { 255, 255, 255 }

  -- terminal velocity
  tv: 200

  new: (@x,@y, @vx=0, @vy=0, @ax=0, @ay=0) =>
    @time = 0

  p: => @time / @life

  update: (dt, world) =>
    @time += dt

    @vx += @ax * dt
    @vy += @ay * dt

    @vx = math.min @tv, @vx
    @vy = math.min @tv, @vy

    @x += @vx * dt
    @y += @vy * dt

    return false unless world.viewport\touches_pt @x,@y
    @time < @life

  draw: =>
    half = @size / 2

    t = @p!
    a = if t > 0.5 then (1-t)*2*255 else 255
    r,g,b = unpack @color

    graphics.setColor r,g,b,a
    graphics.rectangle "fill", @x - half, @y - half, @size, @size

class Emitter
  self.draw_list = nil
  self.emitter_list = nil

  self.draw_all = =>
    if @draw_list
      @draw_list\draw!
      graphics.setColor 255,255,255,255

  self.add = (cls, ...) =>
    @emitter_list = ReuseList! if not @emitter_list
    @emitter_list\add cls, ...

  self.update_all = (dt, world) =>
    @emitter_list\update dt
    @draw_list\update dt, world

  rate: 0.1
  dir: 0
  fan: math.pi/3

  accel: 200
  amount: 15 -- how many particles to spawn before death

  new: (@world, @x, @y, @particle_cls=Particle) =>
    if not Emitter.draw_list
      Emitter.draw_list = ReuseList!

    @time = @rate

  spawn: =>
    return if @amount == 0 -- no more particles!
    dir = @dir + (math.random! - 0.5) * @fan
    dx, dy = math.cos(dir), math.sin(dir)

    Emitter.draw_list\add @particle_cls, @x, @y, 0, 0, dx*100, dy*100
    @amount -= 1

  update: (dt) =>
    @time += dt
    while @time > @rate
      @spawn!
      @spawn!
      @time -= @rate

    @amount > 0

module "particles", package.seeall

class Spark extends Particle
  color: { 255, 211, 118 } -- the spark?

