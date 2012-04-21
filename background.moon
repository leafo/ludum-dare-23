
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

class Background
  watch_class self

  height: 200
  padding: 3

  collide_padding: 2

  new: (@viewport) =>
    @tile = imgfy"img/tile.png"
    @tile\set_wrap "repeat", "repeat"

    @stars = Paralax "img/stars.png", @viewport
    @stars2 = Paralax "img/stars2.png", @viewport, {
      speed: 8
      scale: 0.5
    }

    @terrain = MultiParalax {
      "img/terrain1.png"
      "img/terrain2.png"
    }, @viewport, {
      speed: 32
    }

    @span = 1

    @elapsed = 0

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

  collides: (thing) =>
    return false unless @box
    not @box\contains_box thing.box

  update: (dt) =>
    @elapsed += dt
    @effect\send "time", @elapsed

    @stars\update dt
    @stars2\update dt
    @terrain\update dt

    -- x = @viewport\unproject mouse.getPosition!
    -- @padding = 50 * x / @viewport.w

    @box = Box @padding + @collide_padding, 0,
      @viewport.w - 2 * (@padding + @collide_padding), @viewport.h

  draw: =>
    @stars\draw!
    @stars2\draw!

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

