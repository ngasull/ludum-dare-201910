extends KinematicBody2D

const Impact = preload("res://Impact.tscn")

var max_velocity
var velocity = Vector2()
var lifetime = 0

func init(position, max_velocity):
  self.position = position
  self.velocity = max_velocity / 4
  self.max_velocity = max_velocity

func explode_meaningfully():
  explode(position + velocity.normalized() * 16)
  queue_free()

func explode(at_pos):
  var impact = Impact.instance()
  impact.position = position + velocity.normalized() * 16
  get_parent().add_child_below_node(self, impact)
  $AudioStreamPlayer.play()

func _physics_process(dt):
  if velocity.abs() < max_velocity.abs():
    velocity += dt * max_velocity

  var collision = move_and_collide(velocity)
  if collision:
    queue_free()
    if collision.collider.has_method("hit_by_bullet"):
      collision.collider.hit_by_bullet()
    if collision.collider.is_in_group("shows_bullet_impact"):
      explode(position)