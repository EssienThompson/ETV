extends Node3D

@export var stepTarget : Node3D
@export var stepDist : float = 3.0
@export var stepHeight : float = 1.5
@export var adjacent_target: Node3D
@onready var pare = get_parent()
@onready var previousRotation = pare.transform.basis.get_rotation_quaternion()

var isStepping : bool = false

func _process(delta: float) -> void:
	var currRotate = pare.transform.basis.get_rotation_quaternion()
	var angleDiff = rad_to_deg(currRotate.angle_to(previousRotation))
	if  not isStepping and !adjacent_target.isStepping and (abs(global_position.distance_to(stepTarget.global_position)) > stepDist) or angleDiff > 75.0:
		step()

func step():
	var tarPos = stepTarget.global_position
	var halfWay = (global_position + stepTarget.global_position)/2
	isStepping = true
	previousRotation = pare.transform.basis.get_rotation_quaternion()
	var t = get_tree().create_tween()
	if global_position.distance_to(tarPos) > stepDist:
		halfWay.y +=stepHeight
	t.tween_property(self, "global_position", halfWay, 0.1).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "global_position", tarPos, 0.1).set_ease(Tween.EASE_IN)
	t.tween_callback(func(): isStepping = false)
	t.play()
	
