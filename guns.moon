
g = love.graphics
import graphics, timer, keyboard from love

export *

class Bullet extends Box
  self.sprite = nil

  vel: Vec2d 0, -140
  cell_id: 0

  ox: 1
  oy: 2
  w: 3
  h: 8

  damage: 166

  new: (x, y, vx, vy) =>
    if not Bullet.sprite
      Bullet.sprite = with Spriter imgfy"img/sprite.png", 16, 20
        .oy = 20

    @hits = nil
    @vel = Vec2d vx, vy if vx
    super x, y, @w, @h

  update: (dt, world) =>
    @move unpack @vel * dt
    world.viewport\contains_box self

  draw: =>
    Bullet.sprite\draw_cell @cell_id, @x - @ox, @y - @oy
    @outline!

  on_hit: =>
    @alive = false

class AnimBullet extends Bullet
  seq: {0, 1, 2}
  new: (...) ->
    super ...
    @anim = Animator Bullet.sprite, @seq, 0.2

  update: (dt, world) =>
    @anim\update dt
    super dt, world

  draw: =>
    @anim\draw @x - @ox, @y - @oy

class SimpleBullet extends AnimBullet
  nil

class AbsorbBullet extends AnimBullet
  damage: 1
  seq: {7, 8, 9}

  on_hit: =>
    game.world.bg\feed_energy 2
    super!

class EnemyBullet extends AnimBullet
  damage: 20
  seq: { 3 ,4 }

  ox: 3
  oy: 3

  w: 2
  h: 2

class Gun
  bullet_type: SimpleBullet
  curr_level: 1
  rate: 0.5

  shoot_points: { {1, -4} }

  levels: {
    {}
    {
      rate: 0.3
      shoot_points: {{-2, -3}, {6, -3}} -- wings
    }
  }

  prop: (name) =>
    @levels[@curr_level][name] or self[name]

  new: (@player) =>
    @last_shot = 0
    @cur_point = 1

  shoot: => -- attempt to fire
    time = timer.getTime!
    if time - @last_shot > @prop"rate"
      @fire!
      @last_shot = time

  fire: => -- actually firing
    pts = @prop"shoot_points"
    @cur_point = 1 if @cur_point > #pts
    pt = pts[@cur_point]
    @cur_point += 1

    x, y = @player.box.x + pt[1], @player.box.y + pt[2]

    emitters.ShootBlue\add @player.world, x, y
    @player.bullets\add @bullet_type, x, y

module "guns", package.seeall

class Alpha extends Gun
  is_max: => @curr_level == #@levels

  upgrade: =>
    @curr_level = math.min @curr_level + 1, #@levels

class Beta extends Gun
  bullet_type: AbsorbBullet

