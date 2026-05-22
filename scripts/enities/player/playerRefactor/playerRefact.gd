extends CharacterBody3D

@onready var inputGatherer : InputGatherer = $input
@onready var model : playerModel = $model
var dying = false
var mapOpen = false
var damage = 0
var team = 0
var hurtType = 0
var postureDamage = 0

var actionable := true
var frameDelay := 0.0
var mode := 0 #0 explore, 1 combat, 2 dialogue

func _ready():
	# Initialization
	pass
	

func _physics_process(delta):
	if Input.is_action_pressed("test"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# 1. Gather input
	var inputPackage = inputGatherer.gather_input()
	
	# 2. Update state machine
	model.update(inputPackage, delta)
	
	# 3. Apply velocity and move
	move_and_slide()

   
