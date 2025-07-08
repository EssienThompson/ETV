extends CanvasLayer
var timer := 0.0
var pop := false
var select := false
@export var id := 0
@export var relicName : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	Events.relicSelected.connect(relicSelected)
	Events.gameResumed.connect(selectOff)
	Events.optionsOpened.connect(selectOff)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if pop:
		timer += delta
		if timer >= 3:
			pop = false
			timer = 0
			
	if select or pop:
		visible = true
	else:
		visible = false
		
		

func relicSelected(buttonId : int):
	if buttonId == id:
		if select == false:
			select = true
		elif select:
			select = false
	else:
		select = false
		
		
func selectOff():
	select = false
