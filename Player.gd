extends KinematicBody2D

const Bullet = preload("res://Bullet.tscn")
const GRAVITY = 1000.0
const WALK_SPEED = 75
const RUN_SPEED = 200
const FALL_SPEED = 300
const JUMP_POWER = 300
const BULLET_DELAY = 0.1
const SHAKE_TOTAL = 1.5

var dialog_layer
var level

var is_flipped = false
var is_jumping = false
var is_running = false
var flower_count = 0 setget set_flower_count
var kill_count = 0
var velocity = Vector2()
var bullet_cooldown = 0
var shake_state = 0
var shake_side = 1
var cheat = false

var minigun = false setget set_minigun

func init(dialog_layer, level):
  self.dialog_layer = dialog_layer
  self.level = level

func _process(dt):
  bullet_cooldown -= dt
  if minigun && bullet_cooldown < 0 && Input.is_action_pressed("ui_cancel"):
    bullet_cooldown = BULLET_DELAY
    var bullet = Bullet.instance()
    bullet.init(
      position + Vector2((-1 if is_flipped else 1) * rand_range(28, 36), 16),
      Vector2((-1 if is_flipped else 1) * 15, rand_range(0, -4))
    )
    get_parent().add_child(bullet)
    $AudioShoot.play()

  if shake_state > 0:
    shake_state -= dt
    shake_side *= -1
    $Camera2D.position.y = shake_side * 16 * shake_state / SHAKE_TOTAL
  elif $Camera2D.position.y != 0:
    $Camera2D.position.y = 0

func _physics_process(dt):
  if Input.is_action_just_pressed("cheat"):
    cheat = !cheat
    flower_count += 1

  if is_jumping && is_on_floor():
    is_jumping = false
    $Sprite/AnimationPlayer.play("land")
  elif !is_jumping && velocity.y < 0:
    velocity.y = 0

  velocity.y = min(velocity.y + dt * GRAVITY, FALL_SPEED)

  if Input.is_action_pressed("ui_left"):
    velocity.x = -get_speed()
    flip_h(true)

    if !is_landing():
      $Sprite/AnimationPlayer.play("walk")
    if is_on_echelle():
      velocity.y = -get_speed() * 0.5
  elif Input.is_action_pressed("ui_right"):
    velocity.x = get_speed()
    flip_h(false)
    $Sprite/AnimationPlayer.play("walk")

    if !is_landing():
      $Sprite/AnimationPlayer.play("walk")
    if is_on_echelle():
      velocity.y = -get_speed() * 0.5
  elif is_on_floor():
    velocity = Vector2()
    if !is_landing():
      $Sprite/AnimationPlayer.play("idle")
  else:
    velocity.x = 0

  if Input.is_action_just_pressed("ui_accept") && can_jump():
    velocity.y = -JUMP_POWER
    is_jumping = true
    $AudioJump.play()

  velocity = move_and_slide(velocity, Vector2(0, -1))

  for i in get_slide_count():
    var collision = get_slide_collision(i)
    if collision && collision.collider.is_in_group('officer') && !collision.collider.flee:
      hit_by_officer(collision.collider)

func flip_h(flip):
  is_flipped = flip
  $Sprite.flip_h = flip
  $Minigun.flip_h = flip
  $Minigun.position.x = (-1 if flip else 1) * abs($Minigun.position.x)

func get_speed():
  return 800 if cheat else WALK_SPEED if flower_count == 0 else RUN_SPEED

func can_jump():
  return cheat || flower_count > 0 && (is_on_floor() || is_on_echelle())

func is_on_echelle():
  return $RayOnEchelleBot.is_colliding() || $RayOnEchelleTop.is_colliding() || $RayOnEchelleBotL.is_colliding() || $RayOnEchelleTopL.is_colliding()

func is_landing():
  return $Sprite/AnimationPlayer.current_animation == "land" && $Sprite/AnimationPlayer.is_playing()

func say(texts):
  var position_override = get_viewport().size / 8 + Vector2(200, 0)
  yield(dialog_layer.dialog(texts, false, position_override), "completed")

func set_flower_count(new_flower_count):
  if flower_count == 0 && new_flower_count > 0:
    $Sprite/AnimationPlayer.playback_speed = 2

  flower_count = new_flower_count

func set_minigun(new_minigun):
  minigun = new_minigun
  $Minigun.visible = new_minigun

func hit_by_officer(officer):
  yield(dialog_layer.dialog(["You've been caught by an officer."], true), "completed")
  dialog_layer.final = true

  if kill_count == 0:
    if flower_count == 1:
      dialog_layer.dialog(["Picking flowers is bad,\nbut the officer gave you\na warning and let you go."], true)
    else:
      dialog_layer.dialog([
        "After repeating flower picking\ndespite officer's warning, you've been\ntaken to the police headquarters.",
        "You've spent hours there until\nyour mom testified that you're\na good person, and let you go.",
      ], true)
  else:
    dialog_layer.dialog(["Flower picking is not as\nbad as killing people. You are\narrested"], true)

func shake():
  shake_state = SHAKE_TOTAL