extends Node2D

const Level0 = preload("res://Level0.tscn")

var level

func _ready():
  reset()

func _process(dt):
  if !level && Input.is_action_just_pressed("ui_accept"):
    start()

func reset():
  if level:
    level.queue_free()
  level = null
  $TitleScreen/Root.visible = true

func start():
  $TitleScreen/Root.visible = false
  level = Level0.instance()
  level.init($DialogLayer)
  call_deferred("add_child_below_node", self, level)

func _on_DialogLayer_reset_level():
  call_deferred("reset")
