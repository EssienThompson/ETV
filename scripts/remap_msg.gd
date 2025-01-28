extends MarginContainer
@onready var remap_text: Label = $ColorRect/remapText


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.buttonRemapped.connect(showMsg)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func showMsg(input:String):
	if input == "Keyboard":
		remap_text.text = "Currently remapping Keyboard key"
		visible = true
	elif input == "Controller":
		remap_text.text = "Currently remapping Controller key"
		visible = true
	else:
		visible = false
