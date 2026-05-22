extends Control

@export var height: float = 118.0
@export var dead_zone: float = 5.0    # Minimum distance before registering input
@export var snap_points: int = 0       

var value: float = 0.0  # -1.0 (down) to 1.0 (up)
var direction: float = 0.0  # -1, 0, or 1 for snap points
var activeInput := false
@onready var cursor: TextureRect = $Cursor
@onready var slider: TextureRect = $slider

signal value_changed(new_value: float, direction: float)

func _ready() -> void:
	# Center the indicator initially
	cursor.position.y = size.y / 2.0 - (cursor.size.y * cursor.scale.y)/2.0

func _gui_input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and event is InputEventMouseMotion and activeInput:
		handle_input(event.position.y)

func handle_input(mouse_y: float) -> void:
	var center_y = size.y / 2.0
	var offset_y = center_y - mouse_y  # Positive = up, Negative = down
	
	# Check dead zone
	if abs(offset_y) < dead_zone:
		value = 0.0
		direction = 0.0
		cursor.position.y = center_y - (cursor.size.y * cursor.scale.y)/2.0
		value_changed.emit(value, direction)
		return
	
	# Clamp to height
	offset_y = clamp(offset_y, -height, height)
	
	# Calculate proportional value (-1.0 to 1.0)
	var raw_value = offset_y / height
	
	# Snap if needed
	if snap_points > 0:
		# Convert to snapped positions
		var step = 2.0 / (snap_points - 1) if snap_points > 1 else 2.0
		value = round(raw_value / step) * step
		value = clamp(value, -1.0, 1.0)
		
		# Set direction based on snapped value
		if value > 0:
			direction = 1.0
		elif value < 0:
			direction = -1.0
		else:
			direction = 0.0
	else:
		value = raw_value
		direction = 1.0 if value > 0 else (-1.0 if value < 0 else 0.0)
	
	# Position cursor
	var cursor_y = center_y - value * height
	cursor.position.y = cursor_y - (cursor.size.y * cursor.scale.y) / 2.0
	
	value_changed.emit(value, direction)
	
func active(state: bool):
	if state:
		activeInput = true
		visible = true
	else:
		activeInput = false
		visible = false
	
