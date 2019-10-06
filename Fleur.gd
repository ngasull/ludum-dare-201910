extends Area2D

var elapsed = 0

func _process(dt):
  elapsed += dt
  $Sprite.offset = Vector2(0, 2 * cos(elapsed * 3))

func _on_Fleur_body_shape_entered(body_id, body, body_shape, area_shape):
  if body.is_in_group("player"):
    call_deferred("player_entered", body)

func player_entered(player):
  if player.flower_count == 0:
    yield(player.say(["I've never had success in my life..."]), "completed")
    position = player.position + Vector2(3, 3)
    yield(player.say(["But at least I know how\nto enjoy the moment!"]), "completed")

  player.flower_count += 1
  queue_free()
