
import graphics, timer, keyboard from love
export *

class EffectList
  watch_class self

  new: (@obj) =>
    @current_effects = {}

  clear: (@obj) =>
    for k in pairs @current_effects
      @current_effects[k] = nil

    for i=1,#self
      self[i] = nil

  add: (effect) =>
    existing = @current_effects[effect.__class]
    if existing
      effect\replace self[existing]
      self[existing] = effect
    else
      table.insert self, effect
      @current_effects[effect.__class] = #self

  update: (dt) =>
    for i, e in ipairs self
      finished = e\update dt
      if finished
        @current_effects[e.__class] = nil
        table.remove self, i

  apply: (fn) =>
    e\before @obj for e in *self
    fn!
    e\after @obj for e in *self

class Effect
  new: (@duration) =>
    @time = 0

  -- return true when finished
  update: (dt) =>
    @time += dt
    @time >= @duration

  p: => math.min 1, @time / @duration

  replace: (other) => -- called when replacing existing of same type

  before: => @tmp_color = {graphics.getColor!}
  after: => graphics.setColor @tmp_color

module "effects", package.seeall

class Flash extends Effect
  new: (duration, @color={255,0,0}) =>
    super duration

  before: =>
    super!
    t = @p!

    graphics.setColor {
      @color[1] * (1 - t) + 255 * t
      @color[2] * (1 - t) + 255 * t
      @color[3] * (1 - t) + 255 * t
    }

class Fade extends Effect
  new: (duration, @color) =>
    super duration

class Death extends Effect
  new: (...) =>
    super ...
    @dir = math.random 2

  before: (o) =>
    super!
    t = @p!

    ox, oy = o.box\center!

    c = (1-t)*255
    graphics.setColor 255,c,c,c
    graphics.push!

    graphics.translate ox, oy -- move back

    r = t*math.pi/1.5
    r = -r if @dir == 2
    graphics.rotate r

    ss = (1 - t) / 2 + 0.5
    graphics.scale ss, ss

    graphics.translate -ox, -oy -- move to zero

  after: =>
    graphics.pop!
    super!


