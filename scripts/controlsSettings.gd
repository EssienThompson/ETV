extends Control

@onready var inputButtonRemap = preload("res://scenes/menu&ui/InputButton(Remap).tscn")
@onready var actionList =  $PanelContainer/graphicsHeaders/VBoxContainer/ScrollContainer/ActionList

var isRemapping := false
var actionToRemap = null
var remappingButton = null

var inputActions = {
	"move_forward": "Move forward",
	"move_left": "Move left",
	"move_right": "Move right",
	"move_back": "Move back",
	"Jump": "Jump",
	"sprint": "Dodge",
	"attack": "Attack",
	"block" : "Block",
	"lock_on": "Lock on",
	"map": "Map"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	createActionList()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func closePage(opt:bool):
	#toggleButtons(opt)
	visible = !opt
	
func createActionList():
	InputMap.load_from_project_settings()
	for item in actionList.get_children():
		item.queue_free()
		
	for action in inputActions:
		var button = inputButtonRemap.instantiate()
		var actionLabel = button.find_child("LabelAction")
		var inputLabel = button.find_child("LabelInput")
		
		actionLabel.text = inputActions[action]
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			inputLabel.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			inputLabel.text = ""
			
		actionList.add_child(button)
		button.pressed.connect(_on_input_button_pressed.bind(button, action))
		
func _on_input_button_pressed(button, action):
	if !isRemapping:
		isRemapping = true
		actionToRemap = action
		remappingButton = button
		button.find_child("LabelInput").text = "Press key to bind.."
		Events.buttonRemapped.emit("Keyboard")
	
func _input(event):
	if isRemapping:
		if event is InputEventKey or (event is InputEventMouseButton && event.pressed):
			if event is InputEventMouseButton && event.double_clicked:
				event.double_clicked = false
			
			InputMap.action_erase_events(actionToRemap)
			InputMap.action_add_event(actionToRemap, event)
			updateActionList(remappingButton, event)
			
			isRemapping = false
			actionToRemap = null
			remappingButton = null
			Events.buttonRemapped.emit("close")
			
			accept_event()
			
func updateActionList(button, event):
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")


func _on_reset_pressed() -> void:
	createActionList()
