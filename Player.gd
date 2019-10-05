extends KinematicBody2D

const GRAVITY = 1000.0
const WALK_SPEED = 75
const RUN_SPEED = 200
const FALL_SPEED = 300
const JUMP_POWER = 300

var dialogLayer
var level

var flower_count = 0
var velocity = Vector2()
var cheat = false

func init(dialogLayer, level):
  self.dialogLayer = dialogLayer
  self.level = level  

func _physics_process(dt):
  if Input.is_action_just_pressed("cheat"):
    cheat = !cheat
    
  #if $RayOnGround.is_colliding():
  #  velocity.y = 0
  #  position.y += $RayOnGround.get_collision_point().y - $RayOnGround.global_position.y
  #else:
  velocity.y = min(velocity.y + dt * GRAVITY, FALL_SPEED)

  if Input.is_action_pressed("ui_left"):
    velocity.x = -get_speed()
    $Sprite.flip_h = true
    
    if $RayOnSlopeL.is_colliding():
      var slopeAngle = abs($RayOnSlopeL.get_collision_normal().angle_to(Vector2(0, -1)))
      if abs(slopeAngle - PI/4) < 0.1:
        velocity.y = -get_speed() * 0.5
    if is_on_echelle():
      velocity.y = -get_speed() * 0.5
  elif Input.is_action_pressed("ui_right"):
    velocity.x = get_speed()
    $Sprite.flip_h = false
    
    if $RayOnSlope.is_colliding():
      var slopeAngle = abs($RayOnSlope.get_collision_normal().angle_to(Vector2(0, -1)))
      if abs(slopeAngle - PI/4) < 0.1:
        velocity.y = -get_speed() * 0.5
    if is_on_echelle():
      velocity.y = -get_speed() * 0.5
  else:
    velocity.x = 0
    
  if Input.is_action_just_pressed("ui_accept") && can_jump():
    velocity.y = -JUMP_POWER
  
  move_and_slide(velocity, Vector2(0, -1))

func get_speed():
  return 800 if cheat else WALK_SPEED if flower_count == 0 else RUN_SPEED

func can_jump():
  return cheat || flower_count > 0
  
func is_on_echelle():
  return $RayOnEchelleBot.is_colliding() || $RayOnEchelleTop.is_colliding() || $RayOnEchelleBotL.is_colliding() || $RayOnEchelleTopL.is_colliding()
  
func say(texts):
  yield(dialogLayer.dialog(texts), "completed")
