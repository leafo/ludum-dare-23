
import graphics, timer, keyboard from love

export *

-- class EnemySpanwer extends Sequence
--   nil

class RandomEnemySpanwer extends Sequence
  new: (@world) =>
    @enemies = ReuseList!

    super ->
      wait 1
      @spawn!
      again!

  spawn: => -- need the enemy size
    bg = @world.bg
    x = bg.box.x + math.random bg.box.w
    @enemies\add enemies.First, @word, x, -20

  update: (dt) =>
    super dt
    @enemies\update dt

  draw: =>
    @enemies\draw!

class Enemy extends Entity
  watch_class self

  self.sprite = nil
  sprite_id: 0
  ox: 0
  oy: 0

  new: (w, x, y) =>
    if not Enemy.sprite
      Enemy.sprite = Spriter imgfy"img/sprite.png", 16, 20

    super w, x, y
    @velocity = Vec2d 0, 50

  update: (dt) =>
    @box\move unpack @velocity * dt
    true -- stay alive!

  draw: =>
    Enemy.sprite\draw_cell @sprite_id, @box.x - @ox, @box.y - @oy
    -- @box\outline!

module "enemies", package.seeall

class First extends Enemy
  sprite_id: 3
  w: 8
  h: 9
  ox: 4
  oy: 6

