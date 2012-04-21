
import timer, keyboard from love

export *

-- go to zero
dampen = (val, speed, dt) ->
  amount = speed * dt
  if val > 0
    math.max 0, val - amount
  elseif val < 0
    math.min 0, val + amount
  else
    val

class Player extends Entity
  watch_class self

  controls: {
    shoot: " "
  }

  speed: 100
  decay_speed: 100*3
  accel: 20

  w: 12
  h: 12

  ox: 2
  oy: 8

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

    @movement_lock = 0

  draw: =>
    @sprite\draw_cell 0, @box.x - @ox, @box.y - @oy
    @bullets\draw!

    @box\outline!

  shoot: =>
    pt = @shoot_points[@cur_point]
    @bullets\create_bullet @box.x + pt[1], @box.y + pt[2]

    @cur_point += 1
    @cur_point = 1  if @cur_point > #@shoot_points

  update: (dt) =>
    @bullets\update dt

    @movement_lock = math.max 0, @movement_lock - dt

    if @movement_lock == 0
      move = movement_vector(@speed) * dt * @accel
      @velocity += move

      @velocity\truncate @speed

      if move[1] == 0
        @velocity[1] = dampen @velocity[1], @decay_speed, dt

      if move[2] == 0
        @velocity[2] = dampen @velocity[2], @decay_speed, dt

    cx, cy = @fit_move unpack @velocity * dt
    if cx
      @movement_lock = 0.1
      @velocity[1] = -@velocity[1]

    -- see if we are shooting
    if keyboard.isDown @controls.shoot
      t = timer.getTime!
      if t - @last_shot > @fire_rate
        @shoot!
        @last_shot = t

