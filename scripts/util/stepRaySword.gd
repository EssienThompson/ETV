extends RayCast3D

@export var stepTar : Node3D 
@export var rayRest : Node3D
@onready var cont: Node3D = $"../.."
@onready var offset := stepTar.global_position - cont.global_position
var yHol := 0.0

func _physics_process(delta: float) -> void:
	
	var hitPoint = get_collision_point()
	if hitPoint && !cont.isAtking && !cont.parried:
		stepTar.global_position = hitPoint
		yHol = stepTar.global_position.y
	elif cont != null:
		if cont.parried:
			stepTar.global_position.y = yHol
			
func resetPos():
	stepTar.global_position = rayRest.global_position
	
