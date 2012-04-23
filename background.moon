
g = love.graphics
import mouse from love

export *


class Paralax
  speed: 4
  scale: 0.5

  new: (@img, @viewport, opts={}) =>
    @img = imgfy @img
    @img\set_wrap "repeat", "repeat"

    self[k] = v for k,v in pairs opts

    w, h = @img\width!, @img\height!
    @quad = g.newQuad 0, 0, @viewport.w, @viewport.h, w*@scale, h*@scale

    @offset = 0

  update: (dt) =>
    @offset += dt * @speed
    if @offset > @viewport.h
      @offset -= @viewport.h

  draw: =>
    @img\drawq @quad, 0, @offset - @viewport.h
    @img\drawq @quad, 0, @offset

-- this is useless
class MultiParalax extends Paralax
  new: (imgs, viewport, opts) =>
    @imgs = for img in *imgs
      with imgfy(img)
        \set_wrap "repeat", "repeat"

    super @imgs[1], viewport, opts
    @img2 = @imgs[2]

  update: (dt) =>
    @offset += dt * @speed
    if @offset > @viewport.h
      @offset -= @viewport.h
      @img, @img2 = @img2, @img

  draw: =>
    @img\drawq @quad, 0, @offset - @viewport.h
    @img2\drawq @quad, 0, @offset


class SpaceParticle extends Particle
  new: (...) =>
    super ...
    for i=1,4
      @cell_id = math.random 0, 3
      break if @cell_id != @@last_id

    @@last_id = @cell_id
    @rot_speed = math.random! / 10

  draw: =>
    if not @sprite
      @sprite = Spriter imgfy"img/space_junk.png", 64, 64

    ox, oy = @x + @sprite.cell_w/2, @y + @sprite.cell_h/2

    -- rotate!
    g.push!
    g.translate ox, oy
    g.rotate @time * @rot_speed
    g.translate -ox, -oy

    @sprite\draw_cell @cell_id, @x, @y

    g.pop!

  update: (dt) =>
    @time += dt
    @x += dt * @vx
    @y += dt * @vy
    true

class SpaceJunk extends Emitter
  draw_list: ReuseList!

  amount: nil
  default_particle: SpaceParticle
  rate: 3
  dir: math.pi / 2
  fan: 0
  vel: 20

  spawn: (...) =>
    @x = math.random 10, 40
    @rate = math.random 2, 5
    super ...

class Background
  watch_class self

  height: 200
  padding: 5

  min_padding: 5
  max_padding: 47

  collide_padding: 1

  new: (@viewport) =>
    @update_box!

    @crush_speed = 0.1
    @energy = 0

    @tile = imgfy"img/tile.png"
    @tile\set_wrap "repeat", "repeat"

    @stars = Paralax "img/stars.png", @viewport
    @stars2 = Paralax "img/stars2.png", @viewport, {
      speed: 8
      scale: 0.5
    }

    @terrain = Paralax "img/terrain1.png", @viewport, {
      speed: 32
    }

    @span = 1

    @elapsed = 0

    @fake_world = { viewport: viewport }
    @junk = SpaceJunk @fake_world, 25, -64

    @effect = g.newPixelEffect [[
      extern number time;
      extern bool persp;

      vec4 effect(vec4 color, sampler2D tex, vec2 st, vec2 pixel_coords) {
        float x = 1 - st.x;
        float y = st.y - 0.5; // center coordinate system
        if (persp) y /= (x * 0.5 + 0.5);
        y += 0.5;

        return texture2D(tex, vec2(x, y*4 - time)) * vec4(vec3(x), sqrt(x));
      }
    ]]

  -- try to make the entity fit
  -- return false if there is no room
  reposition_entity: (entity) =>
    return false if entity.w >= @box.w

    if entity.box\center! < @box\center!
      entity.box.x = @box.x + 0.1
    else
      entity.box.x = @box.x + @box.w - entity.w - 0.1
    true

  collides: (thing) =>
    return false unless @box
    not @box\contains_box thing.box

  update_box: =>
    if @padding != @last_padding
      @box = Box @padding + @collide_padding, 0,
        @viewport.w - 2 * (@padding + @collide_padding), @viewport.h
      @last_padding = @padding

  feed_energy: (amount) =>
    @energy += amount

  update: (dt) =>
    @elapsed += dt
    @effect\send "time", @elapsed

    @junk\update dt
    @junk.draw_list\update dt, @fake_world

    @stars\update dt
    @stars2\update dt
    @terrain\update dt

    -- feed the wall
    if @energy > 0
      @padding -= @energy * 8 * dt
      @energy -= dt * 16
      @padding = math.max @min_padding, @padding

    @padding += @crush_speed*dt
    @padding = math.min @max_padding, @padding

    @crush_speed += dt / 30

    @update_box!

  draw: =>
    @stars\draw!
    @stars2\draw!

    @junk.draw_list\draw!

    @terrain\draw!

    g.setPixelEffect @effect

    sy = @height / @tile\width!
    sx = (1 - @padding / 50) * 0.8

    @effect\send "persp", 1

    -- left
    @tile\draw @padding, -25, 0, sx, sy
    -- right
    @tile\draw @viewport.w - @padding, -25, 0, -sx, sy

    -- top left
    @effect\send "persp", 0
    @tile\draw @padding, -25, 0, -1, sy
    -- top right
    @tile\draw @viewport.w - @padding, -25, 0, 1, sy

    g.setPixelEffect!

    -- @box\outline!

