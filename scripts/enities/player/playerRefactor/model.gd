extends Node
class_name playerModel

var currMove : Move
@onready var player = $".."
@onready var moves = {
	"idle" : $idle,
	"run" : $run,
	"jump" : $jump
}

func _ready() -> void:
	currMove = moves["idle"]
	for move in moves.values():
		move.player = player

func update(input : InputPackage, delta : float):
	var relevance = currMove.checkRelevance(input)
	if relevance != "okay":
		switchTo(relevance)
	currMove.update(input, delta)

func switchTo(state : String):
	currMove.onExitState()
	currMove = moves[state]
	currMove.onEnterState()
