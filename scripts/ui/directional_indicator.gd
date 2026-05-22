extends Control

@export var circle_radius: float = 256.0
@export var dead_zone: float = 40.0    # Minimum distance before registering input
@export var snap_points: int = 0       # 0 = free rotation, 8 = 8-directional snap

var direction: Vector2 = Vector2.ZERO
var angle: float = 0.0
var activeInput := false
var lockEdge := false
var topHalf := false
@onready var cursor: TextureRect = $Cursor

signal direction_changed(new_direction: Vector2, new_angle: float, distance: float)

func _ready() -> void:
	# Center the indicator initially
	cursor.position = size / 2.0 - cursor.size/2.0

func _gui_input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and event is InputEventMouseMotion and activeInput:
		handle_input(event.position)

func handle_input(position: Vector2) -> void:
	var center = size / 2.0
	var offset = position - center
	
	# Check dead zone
	if offset.length() < dead_zone:
		direction = Vector2(0, -1)
		angle = 0.0
		cursor.position = center - cursor.size/2.0
		direction_changed.emit(-direction, angle, 0.0)
		return
		
	var distance = offset.length()
	distance = min(distance, circle_radius)
	
	# Get the normalized direction
	var raw_direction = offset.normalized()
	
	# Calculate angle (0 = up, clockwise)
	angle = atan2(raw_direction.x, -raw_direction.y)
	if angle < 0:
		angle += TAU
	
	if topHalf:
		# Top half is 0 to PI/2 (up-right) and 3*PI/2 to 2*PI (left-up)
		if angle > PI/2 and angle < 3*PI/2:  # Bottom half
			if angle < PI:  # Right-bottom quadrant
				angle = PI/2  # Snap to right
			else:  # Left-bottom quadrant
				angle = 3*PI/2  # Snap to left
		
		direction = Vector2(sin(angle), -cos(angle))
	else:
		direction = raw_direction
		
	## Snap if needed
	#if snap_points > 0:
		#var snap_angle = TAU / snap_points
		#angle = round(angle / snap_angle) * snap_angle
		#direction = Vector2(sin(angle), -cos(angle))
	#else:
		#direction = raw_direction
	
	# Position the indicator proportionally based on distance
	# Normalize distance to 0-1 range for proportional movement
	var proportional_distance
	if lockEdge:
		proportional_distance = 1.0
		cursor.position = center - cursor.size/2.0 + direction * circle_radius
	else:
		proportional_distance = distance / circle_radius
		cursor.position = center - cursor.size/2.0 + direction * distance
	
	direction_changed.emit(-direction, angle, proportional_distance)

func active(state: bool, edgeL: bool = false, topL: bool = false):
	if state:
		activeInput = true
		visible = true
		lockEdge = edgeL
		topHalf = topL
	else:
		activeInput = false
		visible = false
