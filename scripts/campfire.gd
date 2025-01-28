extends Node3D
@onready var interact_area: Area3D = $interactArea
@onready var interactable: Node3D = $interactable

var player
var playerInteractable := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if playerInteractable:
		interactable.visible = true
	else:
		interactable.visible = false
		
	if Input.is_action_just_pressed("interect") && playerInteractable && player.isTalking == false:
		player.currhp = player.maxhp
		#TODO make campfire sit


func _on_interact_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		playerInteractable = true
		player = body


func _on_interact_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		playerInteractable = false
