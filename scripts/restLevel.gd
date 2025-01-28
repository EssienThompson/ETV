extends Node3D
@export var diaID : String
var tut := false
var act := 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.battleWon.emit()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#var ene := get_tree().get_nodes_in_group("enemy")
	#for my in ene:
		#my.hp = 300
		#my.currState = my.State.IDLE
	pass
