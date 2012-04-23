
import graphics, timer, keyboard from love

export *

rr = (min, max) -> math.random! * (max - min) + min

class ShootPattern extends Sequence
  new: (@enemy, fn) =>
    world = @enemy.world

    -- this is a mess
    scope = nil
    scope = setmetatable {
      enemy: @enemy,
      player: game.player

      fan_bullets: (deg1, deg2, rate, amount) ->
        if deg1 < deg2
          dd = (deg2 - deg1) / amount
          while deg1 < deg2
            scope.fire deg1
            deg1 += dd
            scope.wait rate if rate and rate > 0

      fire: (deg, speed=40) ->
        deg += 90 -- default to down
        vx, vy = unpack (speed * Vec2d.from_angle deg) + @enemy.velocity

        cx, cy = @enemy.box\center!
        b = EnemyBullet
        world.enemy_bullets\add b, cx - b.w / 2, cy - b.h / 2, vx, vy

    }, __index: Sequence.default_scope

    fn = fn or -> error "must supply pattern"
    super fn, scope

-- convert a percentage coordinate to actual pixel coord
-- x_pos is from -1 to 1, where 0 is the middle of the field
get_x_coord = (x_pos, bg, enemy_type) ->
  cx = bg.box\center!

  min_x = bg.box.x
  max_x = bg.box.x + bg.box.w - enemy_type.w

  space = max_x - min_x
  if space <= enemy_type.w
    return nil

  x_pos = (x_pos + 1) / 2
  math.floor min_x + x_pos * space

clamp = (t) -> math.min 1, math.max 0, t

bez_3 = (v0, v1, v2, t) -> 0

-- first derivative of quadratic bezier
bez_3_d = (v0, v1, v2, t) ->
  2 * (1 - t) * (v1 - v0) + 2 * t * (v2 - v1)

ai = {
  -- what in the heck will this do
  swoop: (world, speed, v0, v1, v2) ->
    scale_v = (vec) ->
      v = world.viewport
      Vec2d vec[1] * v.w, vec[2] * v.h

    v0 = scale_v v0
    v1 = scale_v v1
    v2 = scale_v v2

    (thing, dt, world) ->
      t = clamp thing.box.y / world.viewport.h
      thing.velocity = dt * speed * bez_3_d v0, v1, v2, t

  straight: (speed) ->
    vec = Vec2d 0, speed
    (thing, dt, world) ->
      thing.velocity = vec
}

ai_combine = (a1, a2) ->
  (...) ->
    a1 ...
    a2 ...

class EnemyWave extends Sequence
  new: (@world, @enemy_list, @wave) =>
    scope = setmetatable {
      spawn: (cls, x_pos=0, ai=nil) ->
        -- try to find a place to spawn
        x = nil
        while true
          x = get_x_coord x_pos, @world.bg, cls
          break if x
          coroutine.yield!

        @enemy_list\add cls, @world, x, -20, ai

      -- have to be careful about reusing enemies
      wait_enemies: (es) ->
        alive = { e, true for e in *es }

        while true
          for e in *es
            if alive[e] and not e.alive or e.health <= 0
              alive[e] = nil

          if next alive
            coroutine.yield!
          else
            break

    }, __index: Sequence.default_scope

    import Red, Pink, White from enemies
    import straight, swoop from ai

    swoop_right = swoop @world, 20,
      Vec2d(0.3, 0.0),
      Vec2d(0.8, 0.8),
      Vec2d(0.0, 3.0)

    swoop_left = swoop @world, 20,
      Vec2d(-0.3, 0.0),
      Vec2d(-0.8, 0.8),
      Vec2d(-0.0, 3.0)

    wave = ->
      wait 1

      send_row = (pos, etype=Red) ->
        e = nil
        spd = math.random 50, 60
        for i=1,4
          e = spawn etype, pos, straight spd
          wait 0.4
        e\attach_powerup shuffle_powerup!
        e

      send_row -0.3
      wait 1.0
      wait_enemies { send_row 0.3 }

      wait_enemies {
        spawn Pink, 0.3, swoop_right
        spawn Pink, -0.3, swoop_left
      }

      wait 1.0

      wait_enemies {
        with spawn enemies.Red2, 0, straight 50
          \attach_powerup GunPowerup
      }

      -- white two fans
      for i=1,3
        a,b = -0.4, 0.4
        a,b = b,a if math.random! >= 0.5

        spawn enemies.White2, a, straight 50

        wait rr 0.5,1.5
        wait_enemies {
          with spawn enemies.White2, b, straight 50
            \attach_powerup shuffle_powerup!
        }

      send_row -0.3, White
      wait 1.0
      send_row 0.3, White

      again!

    super wave, scope

class RandomEnemySpanwer extends Sequence
  new: (@world, @enemy_list) =>
    @types = { enemies.Red, enemies.Pink, enemies.White }

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

  new: (w, x, y, @ai) =>
    if not Enemy.sprite
      Enemy.sprite = Spriter imgfy"img/sprite.png", 16, 20

    super w, x, y
    @velocity = Vec2d 0, 50

    @health = 100
    @powerup = nil

    if @effects
      @effects\clear self
    else
      @effects = EffectList self

    if @shoot_template
      @pattern = ShootPattern self, @shoot_template
    else
      @pattern = nil

  attach_powerup: (pclass) =>
    @powerup = pclass

  update: (dt) =>
    @effects\update dt
    @ai dt, @world if @ai

    @box\move unpack @velocity * dt
    v = @world.viewport

    if @health <= 0 and #@effects == 0
      return false

    -- make it follow!
    if @death_emitter and @death_emitter.attach == self
      cx, cy = @box\center!
      @death_emitter.x = cx
      @death_emitter.y = cy

    @pattern\update dt if @pattern and @health > 0

    -- are they in the world?
    @box\above_of v or v\touches_box @box

  die: =>
    sfx\play "die_enemy"
    cx, cy = @box\center!

    if @powerup
      @world.powerups\add @powerup, cx, cy

    @health = 0 if @health > 0
    @velocity[2] /= 2
    @effects\add effects.Death 1.0

    emitters.Explosion\add w, cx, cy
    @death_emitter = with emitters.PourSmoke\add @world, cx, cy
      .attach = self

  take_hit: (bullet) =>
    sfx\play "hit_enemy"
    emitters.HitEnemy\add @world, bullet.x, bullet.y

    @health -= bullet.damage
    if @health <= 0
      @die!
      game.hud.score += 44
    else
      @effects\add effects.Flash 0.1

  draw: =>
    @effects\apply ->
      Enemy.sprite\draw_cell @sprite_id, @box.x - @ox, @box.y - @oy
    -- @box\outline!

module "enemies", package.seeall

class Red extends Enemy
  sprite_id: 3
  w: 8
  h: 9
  ox: 4
  oy: 6

class Pink extends Enemy
  sprite_id: 4
  w: 8
  h: 9
  ox: 4
  oy: 6

class White extends Enemy
  sprite_id: 5
  w: 8
  h: 9
  ox: 4
  oy: 6

class Red2 extends Red
  shoot_template: ->
    wait 1.0
    fire -30
    fire 30
    wait 1.0
    again!


class White2 extends White
  shoot_template: ->
    wait 0.5
    fan_bullets -60, 60, nil, 4

