extends Node2D

const EvilOfficer = preload("res://EvilOfficer.tscn")

const MAX_DISTANCE = 600
const MAX_SOLDIERS = 3

var player

var flee = false setget set_flee
var freeze = false setget set_freeze
var spawned = []

func init(player):
  self.player = player

func set_freeze(new_freeze):
  freeze = new_freeze
  for ennemy in spawned:
    ennemy.freeze = new_freeze

func set_flee(new_flee):
  flee = new_flee
  for ennemy in spawned:
    ennemy.flee = new_flee

func clean_spawned():
  var spawned_i = range(spawned.size())
  spawned_i.invert()
  for i in spawned_i:
    var ennemy = spawned[i]
    if ennemy.position.distance_to(player.position) > MAX_DISTANCE:
      spawned.remove(i)
      ennemy.queue_free()

func trigger_spawn(spawn_trigger):
  clean_spawned()

  var spawners = []
  for child in get_children():
    if child.is_in_group("spawner") && child.position.x < player.position.x:
      spawners.append(child)
  spawners.sort_custom(self, "sort_by_distance")

  for i in MAX_SOLDIERS - spawned.size():
    var spawner = spawners.pop_front()
    if spawner:
      var ennemy = EvilOfficer.instance()
      ennemy.init(spawner.position, player)
      ennemy.flee = flee
      add_child(ennemy)
      spawned.append(ennemy)
      ennemy.connect("tree_exiting", self, "spawnee_remove", [ennemy])
    else:
      break

  spawn_trigger.queue_free()

func sort_by_distance(a, b):
  return player.position.distance_to(a.position) < player.position.distance_to(b.position)

func spawnee_remove(ennemy):
  var i = spawned.find(ennemy)
  if i > -1:
    spawned.remove(i)