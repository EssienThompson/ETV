class_name hitbox
extends Area3D

@export var user : Node3D
var damage
var team
var hurtType
var postureDamage
var userOrigin
var active := false
#var hurtboxHit := []


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("area_entered", self._on_area_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if user != null:
		if user.dying :
			activeOff()
		damage = user.damage
		team = user.team
		hurtType = user.hurtType
		postureDamage = user.postureDamage
		userOrigin = user.global_transform.origin


func _on_area_entered(body):
	pass # Replace with function body.
	
func activeOn():
	active = true
	
func activeOff():
	active = false
	
	
