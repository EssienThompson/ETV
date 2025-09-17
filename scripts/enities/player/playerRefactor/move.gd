extends Node
class_name Move

var player : CharacterBody3D

static var movesPriority : Dictionary = {
	"idle" : 1,
	"run" : 2,
	"jump" : 10
}

static func movesPrioritySort(a : String, b : String):
	if movesPriority[a] > movesPriority[b]:
		return true
	else:
		return false

@warning_ignore("unused_parameter")
func checkRelevance(input : InputPackage) -> String:
	print("error, not implemented")
	return "error, not implemented"
	
func update(input : InputPackage, delta : float):
	pass
	
func onEnterState():
	pass
	
func onExitState():
	pass
