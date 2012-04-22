
g = love.graphics
import graphics, timer, keyboard from love

export *

class Bullet extends Box
  self.sprite = nil
  vel: Vec2d 0, -140

  ox: 1
  oy: 2

  damage: 166

  new: (x, y) =>
    if not Bullet.sprite
      Bullet.sprite = with Spriter imgfy"img/sprite.png", 16, 20
        .oy = 20

    @anim = @anim or Animator Bullet.sprite, {0, 1, 2}, 0.2
    super x, y, 3, 8

  update: (dt, world) =>
    @move unpack @vel * dt
    @anim\update dt
    world.viewport\contains_box self

  draw: =>
    @anim\draw @x - @ox, @y - @oy

  hit_enemy: =>
    @alive = false

class AbsorbBullet extends Bullet
  nil

class Gun
  bullet_type: Bullet
  curr_level: 1
  rate: 0.5

  shoot_points: { {4, 0} }

  levels: {
    {}
    {
      rate: 0.3
      shoot_points: {{0,-2}, {9, -2}} -- wings
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
  shoot: => print "shooting beta!"

