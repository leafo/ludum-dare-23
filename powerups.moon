
g = love.graphics
import timer, keyboard from love
import insert, remove from table

export *

class Powerup
  anim: { 0, 1 }
  speed: 10

  ox: 2
  oy: 2

  w: 5
  h: 4

  new: (x, y) =>
    if not Powerup.sprite
      Powerup.sprite = with Spriter imgfy"img/sprite.png", 16, 20
        .oy = 4 * 20

    @anim = Powerup.sprite\seq @anim, 0.8
    @box = Box x, y, @w, @h
    @vel = Vec2d 0, 1

  draw: =>
    @anim\draw @box.x - @ox, @box.y - @oy

  update: (dt) =>
    @anim\update dt
    @vel[1] += math.sin(timer.getTime!) / 100 -- completely random but works well :)

    @box\move unpack dt * @speed * @vel
    true

  on_pickup: (player) =>
    @alive = false
    emitters.RadialBlue\add player.world, @box\center!

class HealthPowerup extends Powerup
  anim: { 2, 3 }
  on_pickup: (player) =>
    super player
    player.health = math.min player.max_health, player.health + 30

class GunPowerup extends Powerup
  anim: { 0, 1 }
  on_pickup: (player) =>
    player.gun.alpha\upgrade!

shuffle_powerup = ->
  r = math.random!
  if r < 0.1
    GunPowerup
  elseif r < 0.5
    HealthPowerup

