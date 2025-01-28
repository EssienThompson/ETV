extends Button
var id : int
var available := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.optionsOpened.connect(availableOff)
	Events.optionsClosed.connect(availableOn)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if available:
		disabled = false
	else:
		disabled = true
	
	
func chngLabel(nam : String):
	text = nam


func _on_pressed() -> void:
	Events.relicSelected.emit(id)
	

func availableOn():
	available = true
	
func availableOff():
	available = false
