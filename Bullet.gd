extends KinematicBody2D

var max_velocity
var velocity = Vector2()
var lifetime = 0

func init(position, max_velocity):
  self.position = position
  self.velocity = max_velocity / 4
  self.max_velocity = max_velocity

func _physics_process(dt):
  if velocity.abs() < max_velocity.abs():
    velocity += dt * max_velocity

  var collision = move_and_collide(velocity)
  if collision:
    queue_free()
    if collision.collider.has_method("hit_by_bullet"):
      collision.collider.hit_by_bullet()