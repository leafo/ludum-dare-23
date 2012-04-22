
import graphics, timer, keyboard from love

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

-- love it!
join = (objs) ->
  {
    all: (fn) ->
      yes = true
      for o in *objs
        yes = fn o
        break if not yes
      yes

    set: (key, value) ->
      for o in *objs
        o[key] = value
  }

class Player extends Entity
  watch_class self

  controls: {
    shoot_one: "x"
    shoot_two: "c"
  }

  speed: 80
  decay_speed: 100*6
  accel: 20

  w: 6
  h: 9

  ox: 5
  oy: 10

  cell_id: 0
  max_health: 100

  new: (...) =>
    super ...
    @sprite = Spriter imgfy"img/sprite.png", 16, 20
    @last_shot = 0
    @bullets = ReuseList!
    @effects = EffectList self

    @cur_point = 1

    @movement_lock = 0
    @health = @max_health

    @guns = {
      alpha: guns.Alpha self
      beta: guns.Beta self
    }

  on_stuck: =>
    if not @world.bg\reposition_entity self
      @die!

  draw: =>
    @bullets\draw!

    return if @health <= 0 and #@effects == 0

    @effects\apply ->
      @sprite\draw_cell @cell_id, @box.x - @ox, @box.y - @oy

    -- @box\outline!

  take_hit: (damage) =>
    return if @health <= 0 -- already dead

    @health = math.max 0, @health - damage

    if @health <= 0
      @die!
    else
      @movement_lock = 0.1
      @effects\add effects.Flash 0.2
      @world.viewport\shake!

  die: =>
    return if @health <= 0 -- already dead!

    @health = 0 if @health > 0

    @movement_lock = nil -- STOP!!
    @effects\add effects.Death 1.0

    cx, cy = @box\center!

    @death_emitters = join {
      emitters.PourSmoke\add @world, cx, cy
      emitters.RadialSpark\add @world, cx, cy
      emitters.BigExplosion\add @world, cx, cy
    }

    @death_emitters.set "attach", self

  update: (dt) =>
    @bullets\update dt, @world
    @effects\update dt

    if @death_emitters
      cx, cy = @box\center!
      running = @death_emitters.all (e) ->
        if e.attach == self
          e.x = cx
          e.y = cy
          true
      @death_emitters = nil if not running

    -- collide
    if @health > 0
      -- enemies
      for e in *@world.enemies
        if e.alive and e.health > 0

          -- see if a bullet is hitting enemy
          for b in *@bullets
            if b.alive and b\touches_box e.box
              e\take_hit b
              b\on_hit!

          -- see if we are hitting enemy
          if @movement_lock == 0 and @box\touches_box e.box
            @take_hit 80
            @velocity = e.box\vector_to(@box)\normalized! * 100
            e\die!

      -- powerups
      for p in *@world.powerups
        if p.alive and @box\touches_box p.box
          p\on_pickup self

      -- enemy bullets
      for b in *@world.enemy_bullets
        if b.alive and @box\touches_box b
          @take_hit b.damage
          b\on_hit!

    -- movement
    if @movement_lock != nil
      @movement_lock = math.max 0, @movement_lock - dt

    if @movement_lock == 0
      move = movement_vector(@speed) * dt * @accel
      @velocity += move

      if move[1] < 0
        @cell_id = 1
      elseif move[1] > 0
        @cell_id = 2
      else
        @cell_id = 0

      @velocity\truncate @speed

      if move[1] == 0
        @velocity[1] = dampen @velocity[1], @decay_speed, dt

      if move[2] == 0
        @velocity[2] = dampen @velocity[2], @decay_speed, dt

    cx, cy = @fit_move unpack @velocity * dt
    if cx -- hit a wall
      @take_hit 5
      @velocity[1] = -@velocity[1]



    if @movement_lock == 0 and @health > 0
      -- see if we are shooting
      @guns.beta\update dt, keyboard.isDown @controls.shoot_two
      @guns.alpha\shoot! if keyboard.isDown @controls.shoot_one

