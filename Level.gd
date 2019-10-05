extends Node2D

func init(dialogLayer):
  $Player.dialogLayer = dialogLayer
  $Player.init(dialogLayer, self)
  