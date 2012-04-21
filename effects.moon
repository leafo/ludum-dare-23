
import graphics, timer, keyboard from love
export *

class EffectList
  new: =>
    @current_effects = {}

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
    e\before! for e in *self
    fn!
    e\after! for e in *self

class Effect
  new: (@duration) =>
    @time = 0

  -- return true when finished
  update: (dt) =>
    @time += dt
    @time >= @duration

  p: => math.min 1, @time / @duration

  replace: (other) => -- called when replacing existing of same type

  before: =>
  after: =>

module "effects", package.seeall

class Flash extends Effect
  new: (duration, @color={255,64,64}) =>
    super duration

  before: =>
    @tmp_color = {graphics.getColor!}
    t = @p!

    graphics.setColor {
      @color[1] * (1 - t) + 255 * t
      @color[2] * (1 - t) + 255 * t
      @color[3] * (1 - t) + 255 * t
    }

  after: =>
    graphics.setColor @tmp_color

class Fade
  new: (duration, @color) =>
    super duration

