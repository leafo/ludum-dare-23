
import graphics, timer, keyboard from love

export *

class Particle
  watch_class self

  size: 1
  life: 1
  color: { 255, 255, 255 }

  -- terminal velocity
  tv: 800

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
    return unless @draw_list
    @draw_list\draw!
    graphics.setColor 255,255,255,255


  self.update_all = (dt, world) =>
    return unless @emitter_list
    @emitter_list\update dt
    @draw_list\update dt, world

  -- this is a class method!!
  add: (cls, ...) ->
    Emitter.emitter_list = ReuseList! if not Emitter.emitter_list
    Emitter.emitter_list\add cls, ...

  ----

  per_frame: 2
  rate: 0.1
  dir: 0
  fan: math.pi/5

  accel: 200
  vel: 0

  amount: 15 -- how many particles to spawn before death

  default_particle: Particle

  new: (@world, @x, @y, @particle_cls=@default_particle) =>
    if not Emitter.draw_list
      Emitter.draw_list = ReuseList!

    @amount = @@amount
    @time = @rate

  spawn: =>
    return if @amount == 0 -- no more particles!
    dir = @dir + (math.random! - 0.5) * @fan
    dx, dy = math.cos(dir), math.sin(dir)

    Emitter.draw_list\add @particle_cls, @x, @y, dx*@vel, dy*@vel, dx, dy*@accel

    @amount -= 1

  update: (dt) =>
    @time += dt
    while @time > @rate
      for i=1,@per_frame
        @spawn!
      @time -= @rate

    @amount > 0

module "particles", package.seeall

class Spark extends Particle
  color: { 255, 211, 118 } -- the spark?
  life: 0.4

  new: (...) =>
    super ...
    if 1 == math.random 8
      @life = math.random! * 3 + 2
    else
      @life = math.random! / 2 + 0.05

class Smoke extends Particle
  size: 3
  color: { 111, 111, 111 }

module "emitters", package.seeall

class HitEnemy extends Emitter
  default_particle: particles.Spark

  per_frame: 4
  rate: 0.05
  amount: 8
  accel: -200
  vel: 100

  dir: math.pi*1.5

