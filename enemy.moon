
import graphics, timer, keyboard from love

export *

-- class EnemySpanwer extends Sequence
--   nil

class RandomEnemySpanwer extends Sequence
  new: (@world, @enemy_list) =>
    @types = { enemies.First, enemies.Second, enemies.Third }

    super ->
      wait 0.5
      @spawn!
      again!

  spawn: => -- need the enemy size
    bg = @world.bg
    x = bg.box.x + 5 + math.random bg.box.w - 5

    cls = @types[math.random(#@types)]

    @enemy_list\add cls, @world, x - math.floor(cls.w/2) , -20

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

    @health = 100

    if @effects
      @effects\clear self
    else
      @effects = EffectList self

  update: (dt) =>
    @effects\update dt

    @box\move unpack @velocity * dt
    v = @world.viewport

    if @health < 0 and #@effects == 0
      return false

    -- are they in the world?
    @box\above_of v or v\touches_box @box

  take_hit: (bullet) =>
    emitters.HitEnemy\add @world, bullet.x, bullet.y


    @health -= bullet.damage
    if @health < 0
      @velocity[2] /= 2
      @effects\add effects.Death 1.0
    else
      @effects\add effects.Flash 0.1

  draw: =>
    @effects\apply ->
      Enemy.sprite\draw_cell @sprite_id, @box.x - @ox, @box.y - @oy
    -- @box\outline!

module "enemies", package.seeall

class First extends Enemy
  sprite_id: 3
  w: 8
  h: 9
  ox: 4
  oy: 6

class Second extends Enemy
  sprite_id: 4
  w: 8
  h: 9
  ox: 4
  oy: 6

class Third extends Enemy
  sprite_id: 5
  w: 8
  h: 9
  ox: 4
  oy: 6

