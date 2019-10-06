extends KinematicBody2D

const GRAVITY = 1000.0
const SPEED = 120
const FALL_SPEED = 300
const JUMP_POWER = 300

var player

var flee = false
var freeze = false
var is_jumping = false
var is_running = false
var velocity = Vector2()
var hp = 3

func init(position, player):
  self.position = position
  self.player = player

func _physics_process(dt):
  if is_jumping && is_on_floor():
    is_jumping = false
  elif !is_jumping && velocity.y < 0:
    velocity.y = 0

  velocity.y = min(velocity.y + dt * GRAVITY, FALL_SPEED)

  if freeze:
    if is_on_floor():
      $AnimationPlayer.stop()
      velocity = Vector2(0, 0)
  else:
    $AnimationPlayer.play("walk")
    if position.direction_to(player.position).x * (-1 if flee else 1) < 0:
      velocity.x = -SPEED
      $Sprite.flip_h = true
    else:
      velocity.x = SPEED
      $Sprite.flip_h = false

  velocity = move_and_slide(velocity, Vector2(0, -1))

  for i in get_slide_count():
    var collision = get_slide_collision(i)
    if !flee && collision && collision.collider == player:
      player.hit_by_officer(self)

func jump():
  velocity.y = -JUMP_POWER

func hit_by_bullet():
  hp -= 1
  if hp < 1:
    queue_free()
  $AudioHurt.play()

func is_on_echelle():
  return $RayOnEchelleBot.is_colliding() || $RayOnEchelleTop.is_colliding() || $RayOnEchelleBotL.is_colliding() || $RayOnEchelleTopL.is_colliding()
