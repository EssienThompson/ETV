# remap_button.gd
extends Button
class_name RemapButton
############################### jump ship
#@onready var contL: Label = $cont
@export var action: String
@export var order: int
var remap := false
var keyCont : String
var key 
var cont 

func _init():
	toggle_mode = true
	theme_type_variation = "RemapButton"


func _ready():
	set_process_unhandled_input(false)
	update_key_text()
	Events.inputType.connect(inputType)

func _process(delta: float) -> void:
	if is_hovered():
		print("ppppppppppp")
		focus()
	
	
func focus():
	grab_focus()

func _toggled(button_pressed):
	remap = button_pressed
	if button_pressed:
		#text = "Awaiting Input"
		Events.buttonRemapped.emit(keyCont)
		release_focus()
	else:
		update_key_text()
		Events.buttonRemapped.emit("close")
		grab_focus()


func input(event):
	if event.pressed && remap:
		if keyCont == "Keyboard":
			key = event
		else:
			cont = event
		replaceAction() ### TODO get this in array and in order and in order again(console/keyboard)
		button_pressed = false



func update_key_text():
	text = "%s" % InputMap.action_get_events(action)[0].as_text()
	#contL.text = "%s" % InputMap.action_get_events(action)[1].as_text()
		
func inputType(type:String):
	keyCont = type
	
func replaceAction():
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, key)
	InputMap.action_add_event(action, cont)
