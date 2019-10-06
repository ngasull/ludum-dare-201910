extends CanvasLayer

signal dialog_accept
signal reset_level

const Dialog = preload("res://Dialog.tscn")

var final = false

func _process(dt):
  if Input.is_action_just_pressed("ui_accept"):
    emit_signal("dialog_accept")

func dialog(texts, evil = false, position_overide = get_viewport().size / 8):
  for text in texts:
    var dialog = Dialog.instance()
    dialog.init(position_overide, text, evil)
    get_tree().paused = true
    add_child(dialog)
    if evil:
      $AudioEvil.play()
    else:
      $AudioLight.play()
    yield(self, "dialog_accept")
    remove_child(dialog)
    get_tree().paused = false

  if final:
    final = false
    emit_signal("reset_level")