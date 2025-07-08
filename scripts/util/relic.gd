extends Node3D
@onready var interact_area: Area3D = $interactArea
@onready var interactable: Node3D = $interactable
@export var id : int
@onready var collision_shape_3d: CollisionShape3D = $StaticBody3D/CollisionShape3D
@onready var canvas_layer: CanvasLayer = $CanvasLayer

var playerInteractable := false
var player
var pickup := true

#When adding a new relic add a unique id and code its effect into player / dont forgor to make a popup and add it to events for loading


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if playerInteractable && pickup:
		interactable.visible = true
	else:
		interactable.visible = false
		
	if !pickup:
		interact_area.monitoring = false
		interact_area.monitorable = false
		collision_shape_3d.disabled = true
		visible = false
	else:
		interact_area.monitoring = true
		interact_area.monitorable = true
		
	if Input.is_action_just_pressed("interect") && playerInteractable && player.isTalking == false:
		pickup = false
		canvas_layer.id = id
		canvas_layer.pop = true
		canvas_layer.relicName = name
		remove_child(canvas_layer)
		player.add_child(canvas_layer)
		player.relicPopup.append(canvas_layer)
		player.relic.append(id)
		Events.relicAdded.emit()
		queue_free()
		


func _on_interact_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		playerInteractable = true
		player = body

func _on_interact_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		playerInteractable = false
