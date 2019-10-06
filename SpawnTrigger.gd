extends Area2D

func _on_SpawnTrigger_body_shape_entered(body_id, body, body_shape, area_shape):
  if body == get_parent().player:
    get_parent().call_deferred("trigger_spawn", self)
