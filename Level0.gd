extends Node2D

var dialog_layer

var minigun_elapsed = 0
var minigun_officer
var minigun_breakable_area
var minigun_breakable_hp = 10

var phase1b_hp = 15
var phase1c_hp = 10

var phase1_in
var phase1b_in
var phase1c_in
var phase2_in

func init(dialog_layer):
  self.dialog_layer = dialog_layer
  $Player.init(dialog_layer, self)
  $Phase1Out/SpawnManager.init($Player)
  $Phase1In/SpawnManager.init($Player)
  $Phase1In/SpawnManager.flee = true
  phase1_in = $Phase1In
  phase1b_in = $Phase1BIn
  phase1c_in = $Phase1CIn
  phase2_in = $Phase2In
  remove_child(phase1_in)
  remove_child(phase1b_in)
  remove_child(phase1c_in)
  remove_child(phase2_in)
  minigun_officer = $MinigunScene/EvilOfficer
  minigun_officer.init(minigun_officer.position, $Player)
  minigun_officer.freeze = true
  minigun_breakable_area = $MinigunScene/BreakableArea2D
  $MinigunScene.remove_child(minigun_officer)
  $MinigunScene.remove_child(minigun_breakable_area)

func _process(dt):
  if has_node("Phase1Out") && Input.is_action_just_pressed("ui_right"):
    $Phase1Out/SpawnManager.freeze = false

  if has_node("MinigunScene") && $MinigunScene.has_node("Minigun"):
    minigun_elapsed += dt
    $MinigunScene/Minigun/Sprite.offset = Vector2(0, 2 * cos(minigun_elapsed * 3))

func _on_FirstSpawnTrigger_body_shape_entered(body_id, body, body_shape, area_shape):
  if body == $Player:
    call_deferred("first_flower_dialog")

func first_flower_dialog():
  yield(dialog_layer.dialog([
    "FUPD, freeze!!",
    "Collecting flowers is strictly forbidden\nby aticle W66TF written in our national\ncode of conduct",
  ], true), "completed")
  yield($Player.say(["But... I just realized that\nI could enjoy life."]), "completed")
  yield(dialog_layer.dialog(["None of our business."], true), "completed")
  $Phase1Out/SpawnManager.freeze = true

func _on_AvatarWtfArea_body_entered(body):
  if body == $Player:
    dialog_layer.dialog([
      "What on earth was that about?!",
      "I'm not a criminal,\nI don't deserve that!",
    ])
    $Phase1Out/AvatarWtfArea.queue_free()

func _on_Minigun_body_shape_entered(body_id, body, body_shape, area_shape):
  call_deferred("minigun_pickup")

func minigun_pickup():
  $MinigunScene/Minigun.queue_free()
  $Player.say(["They gonna see, these suckers!!"])
  $MinigunScene/Area2D.monitoring = true
  $Player.minigun = true

func _on_MinigunScene_Area2D_body_shape_entered(body_id, body, body_shape, area_shape):
  if body == $Player:
    $MinigunScene.add_child(minigun_breakable_area)
    $MinigunScene.add_child(minigun_officer)
    minigun_officer.hp = 20
    $MinigunScene/Area2D.queue_free()
    yield(dialog_layer.dialog([
      "FUPD freez..!",
      "Y... You're under arrest,\nplease drop that gun and\ngently come here."
    ], true), "completed")

func _on_BreakableArea2D_body_entered(body):
  if body.is_in_group("bullet"):
    minigun_breakable_hp -= 1

    if minigun_breakable_hp < 1:
      yield($Player.say(["That's what you get for\nmessing with me, clowns!!"]), "completed")
      $MinigunScene.queue_free()
      add_child_below_node($Phase1Out, phase1_in)
      $Phase1Out.queue_free()

func _on_Phase1BOut_Area2D_body_shape_entered(body_id, body, body_shape, area_shape):
  if body.is_in_group("bullet"):
    phase1b_hp -= 1
    if phase1b_hp < 1:
      call_deferred("trigger_phase1b")

func trigger_phase1b():
  add_child_below_node($Phase1BOut, phase1b_in)
  $Phase1BOut.queue_free()

func _on_Phase1COut_Area2D_body_shape_entered(body_id, body, body_shape, area_shape):
  if body.is_in_group("bullet"):
    phase1c_hp -= 1
    if phase1c_hp < 1:
      call_deferred("trigger_phase1c")

func trigger_phase1c():
  add_child_below_node($Phase1COut, phase1c_in)
  $Phase1COut.queue_free()

func _on_TankAnnounceArea_body_entered(body):
  if body == $Player:
    $Phase1In/TankAnnounceArea.queue_free()
    yield(dialog_layer.dialog([
      "Hey bud",
      "can't wait to see\nwhat you're gonna do against\nthat ninja turtle!",
    ], true), "completed")
    dialog_layer.final = true
    yield(dialog_layer.dialog(["To be continued"], true), "completed")
