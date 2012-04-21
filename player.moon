
import timer, keyboard from love

export *

class Player extends Entity
  watch_class self

  controls: {
    shoot: " "
  }

  speed: 100
  w: 16
  h: 20

  fire_rate: 0.3

  shoot_points: {
    {2,8}, {11, 8}
  }

  new: (...) =>
    super ...
    @sprite = Spriter imgfy"img/sprite.png", 16, 20
    @last_shot = 0
    @bullets = BulletList!

    @cur_point = 1

  draw: =>
    @sprite\draw_cell 0, @box.x, @box.y
    @bullets\draw!

  shoot: =>
    pt = @shoot_points[@cur_point]
    @bullets\create_bullet @box.x + pt[1], @box.y + pt[2]

    @cur_point += 1
    @cur_point = 1  if @cur_point > #@shoot_points

  update: (dt) =>
    @bullets\update dt

    @velocity\update unpack movement_vector @speed

    if keyboard.isDown @controls.shoot
      t = timer.getTime!
      if t - @last_shot > @fire_rate
        @shoot!
        @last_shot = t

    super dt
