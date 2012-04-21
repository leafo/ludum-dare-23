
g = love.graphics

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


