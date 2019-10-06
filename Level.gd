extends Node2D


func init(dialog_layer):
  self.dialog_layer = dialog_layer
  $Player.init(dialog_layer, self)
  $SpawnManager.init($Player)
