class_name  mapRoom
extends Area2D

signal  selected(room:Room)

const ICONS := {
	Room.Type.NOT_ASSIGNED: [null, Vector2.ONE],
	Room.Type.MONSTER: [preload("res://images/owo.png"), Vector2(0.075, 0.075)],
	Room.Type.TREASURE: [preload("res://images/pog.png"), Vector2(0.16, 0.16)],
	Room.Type.REST: [preload("res://images/Lawwi kitty.JPG"), Vector2(0.03, 0.03)],
	Room.Type.SHOP: [preload("res://images/moneyPrime.jpg"), Vector2(0.085, 0.085)],
	Room.Type.BOSS: [preload("res://images/evanDisrepect.png"), Vector2(0.03, 0.03)],
}

@onready var sprite_2d: Sprite2D = $visuals/Sprite2D
@onready var line_2d: Line2D = $visuals/Line2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var colli: CollisionShape2D = $CollisionShape2D

var available := false : set = setAvailable
var room:Room : set = setRoom

func setAvailable(newValue:bool) -> void:
	available = newValue
	
	if available:
		animation_player.play("highlight")
	elif not room.selected:
		animation_player.play("RESET")
		

func setRoom(newData:Room) -> void:
	room = newData
	position = room.position
	line_2d.rotation_degrees = randi_range(0, 360)
	sprite_2d.texture = ICONS[room.type][0]
	sprite_2d.scale = ICONS[room.type][1]
	Events.hideMap.connect(disableColli)
	Events.showMap.connect(enableColli)
	

func showSelected() -> void:
	line_2d.modulate = Color.WHITE


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not available or not event.is_action_pressed("attack"):
		return
		
	room.selected = true
	animation_player.play("select")
	
	
func onMapRoomSelected() -> void:
	selected.emit(room) #called in aniplr when select ani finishes
	
func disableColli() -> void:
	colli.disabled = true
	
func enableColli() -> void:
	colli.disabled = false
	
#func _ready() -> void:
	#var testRoom := Room.new()
	#testRoom.type = Room.Type.REST
	#testRoom.position = Vector2(100, 100)
	#room = testRoom
	#
	#await get_tree().create_timer(3).timeout
	#available = true
