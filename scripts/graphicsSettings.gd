extends Control

@onready var resolution_button: OptionButton = $graphicSelectors/VBoxContainer/resolutionButton
@onready var screen_mode_button: OptionButton = $graphicSelectors/VBoxContainer/screenModeButton
@onready var framerate_button: OptionButton = $graphicSelectors/VBoxContainer/framerateButton
@onready var vsync_button: Button = $graphicSelectors/VBoxContainer/vsyncButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	closePage(true)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func toggleButtons(opt:bool):
	framerate_button.disabled = opt
	vsync_button.disabled = opt
	screen_mode_button.disabled = opt
	resolution_button.disabled = opt
	
func closePage(opt:bool):
	toggleButtons(opt)
	visible = !opt
