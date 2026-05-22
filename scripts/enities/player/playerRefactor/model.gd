extends Node
class_name playerModel

var currMove : Move
@onready var man = $"../man"
@onready var player = $".."
@onready var camera = $"../camRoot"
@onready var arrow: MeshInstance3D = $"../man/Arrow"
@onready var moves = {
	"idle" : $idle,
	"jog" : $jog,
	"jump" : $jump
}

func _ready() -> void:
	currMove = moves["idle"]
	for move in moves.values():
		move.player = player
		move.man = man
		move.camera = camera
		move.arrow = arrow

func update(input : InputPackage, delta : float):
	var relevance = currMove.checkRelevance(input)
	if relevance != "okay":
		switchTo(relevance)
	currMove.update(input, delta)

func switchTo(state : String):
	#print(current_move.move_name + " -> " + state)
	currMove.onExitState()
	currMove = moves[state]
	currMove.onEnterState()
