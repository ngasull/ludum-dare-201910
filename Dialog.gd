extends Label

func init(position, text, evil = false):
  set_begin(position + Vector2(20, 10))
  rect_size.x = 150
  self.text = text

  if evil:
    $NinePatchRect.texture = preload("res://sprites/dialog_evil.png")
