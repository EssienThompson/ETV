class_name Room
extends Resource

enum Type {NOT_ASSIGNED, MONSTER, ELITE, TREASURE, REST, SHOP, BOSS}

@export var type : Type = Type.NOT_ASSIGNED
@export var row : int
@export var column : int
@export var position : Vector2
@export var next_rooms : Array[Room]
@export var selected := false
@export var beaten := false
@export var scene : PackedScene
@export var focus := false


func _to_string() -> String:
	return "%s (%s)" % [column, Type.keys()[type][0]]
