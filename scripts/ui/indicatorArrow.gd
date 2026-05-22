extends MeshInstance3D

@onready var directional_indicator: Control = $"../../CanvasLayer/DirectionalIndicator"
@onready var height_slider: Control = $"../../CanvasLayer/heightSlider"
var direction := Vector3.ZERO
var power := 0.0

func _ready():
	directional_indicator.direction_changed.connect(_on_direction_changed)
	height_slider.value_changed.connect(_on_height_changed)
	active(false,[false,false] ,false)
	# Initialization
	
func _on_direction_changed(new_direction: Vector2, new_angle: float, distance : float):
	direction = Vector3(new_direction.x, direction.y, new_direction.y).normalized()
	#var ang = atan2(direction.x, direction.z) #for direction later in moves
	rotation.y = lerp_angle(rotation.y, -new_angle, 0.25)
	power = distance
	var size = remap(distance, 0, 1.0, 0.1, 0.25)
	scale = Vector3(size, size, size)
	
	
func _on_height_changed(value: float, directionLocked: float):
	var newX = remap(value, -1.0, 1.0, deg_to_rad(-90.0), deg_to_rad(90.0))
	direction = Vector3(direction.x, value, direction.z).normalized()
	rotation.x = lerp_angle(rotation.x, -newX, 0.25)

func active(activeA : bool,activeD : Array, activeH : bool):
	if activeA:
		directional_indicator.active(true, activeD[0], activeD[1])#circle, lockEdge, top-half lock
		height_slider.active(activeH)#slider
		visible = true
	else:
		directional_indicator.active(activeA)
		height_slider.active(activeA)
		visible = false
