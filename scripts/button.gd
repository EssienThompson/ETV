extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#grab_focus()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_hovered():
		grab_focus()
	
	
func focus():
	grab_focus()
