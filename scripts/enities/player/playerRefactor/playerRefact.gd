extends CharacterBody3D

@onready var inputGatherer : InputGatherer = $input
@onready var model : playerModel = $model
var dying = false
var mapOpen = false
var damage = 0
var team = 0
var hurtType = 0
var postureDamage = 0

func _ready():
	# Initialization
	pass

func _physics_process(delta):
	# 1. Gather input
	var inputPackage = inputGatherer.gather_input()
	
	# 2. Update state machine
	model.update(inputPackage, delta)
	
	# 3. Apply velocity and move
	move_and_slide()

   
