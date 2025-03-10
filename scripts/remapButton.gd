extends Button

var action
@onready var cont_icon: TextureRect = $MarginContainer/HBoxContainer/ContIcon


const ABUTTON = preload("res://images/icons/Abutton.png")
const BBUTTON = preload("res://images/icons/Bbutton.png")
const XBUTTON = preload("res://images/icons/Xbutton.png")
const YBUTTON = preload("res://images/icons/Ybutton.png")
const HOMEBUTTON = preload("res://images/icons/Homebutton.png")
const BUMPER_LEFT = preload("res://images/icons/bumperLeft.png")
const BUMPER_RIGHT = preload("res://images/icons/bumperRight.png")
const LTRIGGER = preload("res://images/icons/Ltrigger.png")
const RTRIGGER = preload("res://images/icons/Rtrigger.png")
const DPAD_UP = preload("res://images/icons/dpadUp.png")
const DPAD_DOWN = preload("res://images/icons/dpadDown.png")
const DPAD_LEFT = preload("res://images/icons/dpadLeft.png")
const DPAD_RIGHT = preload("res://images/icons/dpadRight.png")
const LSTICK = preload("res://images/icons/Lstick.png")
const LSTICK_DOWN = preload("res://images/icons/LstickDown.png")
const LSTICK_LEFT = preload("res://images/icons/LstickLeft.png")
const LSTICK_RIGHT = preload("res://images/icons/LstickRight.png")
const LSTICK_UP = preload("res://images/icons/LstickUp.png")
const RSTICK = preload("res://images/icons/Rstick.png")
const RSTICK_DOWN = preload("res://images/icons/RstickDown.png")
const RSTICK_LEFT = preload("res://images/icons/RstickLeft.png")
const RSTICK_RIGHT = preload("res://images/icons/RstickRight.png")
const RSTICK_UP = preload("res://images/icons/RstickUp.png")


func _ready() -> void:
	#grab_focus()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_hovered():
		grab_focus()
	
	
func focus():
	grab_focus()
	
func changeIcon(icon:String):
	match icon:
		"A": 
			cont_icon.texture = ABUTTON
		"B":
			cont_icon.texture = BBUTTON
		"X":
			cont_icon.texture = XBUTTON
		"Y":
			cont_icon.texture = YBUTTON
		"H":
			cont_icon.texture = HOMEBUTTON #might be the back button lmao
		"RBump":
			cont_icon.texture = BUMPER_RIGHT
		"LBump":
			cont_icon.texture = BUMPER_LEFT
		"RTrigg":
			cont_icon.texture = RTRIGGER
		"LTrigg":
			cont_icon.texture = LTRIGGER
		"DpadU":
			cont_icon.texture = DPAD_UP
		"DpadD":
			cont_icon.texture = DPAD_DOWN
		"DpadL":
			cont_icon.texture = DPAD_LEFT
		"DpadR":
			cont_icon.texture = DPAD_RIGHT
		"LSt":
			cont_icon.texture = LSTICK
		"LStU":
			cont_icon.texture = LSTICK_UP
		"LStD":
			cont_icon.texture = LSTICK_DOWN
		"LStL":
			cont_icon.texture = LSTICK_LEFT
		"LStR":
			cont_icon.texture = LSTICK_RIGHT
		"RSt":
			cont_icon.texture = RSTICK
		"RStU":
			cont_icon.texture = RSTICK_UP
		"RStD":
			cont_icon.texture = RSTICK_DOWN
		"RStL":
			cont_icon.texture = RSTICK_LEFT
		"RStR":
			cont_icon.texture = RSTICK_RIGHT
		
func getIcon(icon:String):
	match icon:
		"A": 
			return ABUTTON
		"B":
			return BBUTTON
		"X":
			return XBUTTON
		"Y":
			return YBUTTON
		"H":
			return HOMEBUTTON #might be the back button lmao
		"RBump":
			return BUMPER_RIGHT
		"LBump":
			return BUMPER_LEFT
		"RTrigg":
			return RTRIGGER
		"LTrigg":
			return LTRIGGER
		"DpadU":
			return DPAD_UP
		"DpadD":
			return DPAD_DOWN
		"DpadL":
			return DPAD_LEFT
		"DpadR":
			return DPAD_RIGHT
		"LSt":
			return LSTICK
		"LStU":
			return LSTICK_UP
		"LStD":
			return LSTICK_DOWN
		"LStL":
			return LSTICK_LEFT
		"LStR":
			return LSTICK_RIGHT
		"RSt":
			return RSTICK
		"RStU":
			return RSTICK_UP
		"RStD":
			return RSTICK_DOWN
		"RStL":
			return RSTICK_LEFT
		"RStR":
			return RSTICK_RIGHT
	
func toggleIcon(bol:bool):
	cont_icon.visible = bol
