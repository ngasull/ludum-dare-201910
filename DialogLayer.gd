extends CanvasLayer

signal dialog_accept

const Dialog = preload("res://Dialog.tscn")

func _process(dt):
  if Input.is_action_just_pressed("ui_accept"):
    emit_signal("dialog_accept")

func dialog(texts):
  for text in texts:
    var dialog = Dialog.instance()
    dialog.init(get_viewport().size / 8, text)
    get_tree().paused = true
    add_child(dialog)
    yield(self, "dialog_accept")
    remove_child(dialog)
    get_tree().paused = false
