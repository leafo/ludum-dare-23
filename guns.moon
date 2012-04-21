
g = love.graphics

export *

class BulletList
  new: (@cls=Bullet) =>
    @dead_list = {}

  update: (dt) =>
    for b in *self
      b\update dt unless b.dead
  
  draw: =>
    for b in *self
      b\draw! unless b.dead

  append: (b) =>
    with b
      self[#self + 1] = b

  create_bullet: (...) =>
    top = table.remove @dead_list
    if top
      @cls.__init top, ...
      top
    else
      @append self.cls ...

class Bullet extends Box
  self.sprite = nil
  dead: true
  vel: Vec2d 0, -140

  ox: 1
  oy: 2

  new: (x, y) =>
    @dead = false
    if not Bullet.sprite
      Bullet.sprite = with Spriter imgfy"img/sprite.png", 16, 20
        .oy = 20

    @anim = @anim or Animator Bullet.sprite, {0, 1, 2}, 0.2
    super x, y, 3, 8

  update: (dt) =>
    @move unpack @vel * dt
    @anim\update dt

  draw: =>
    @anim\draw @x - @ox, @y - @oy

