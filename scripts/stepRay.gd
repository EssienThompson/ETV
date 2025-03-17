extends RayCast3D

@export var stepTar : Node3D

func _physics_process(delta: float) -> void:
	var hitPoint = get_collision_point()
	if hitPoint:
		stepTar.global_position = hitPoint
