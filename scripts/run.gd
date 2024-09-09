extends Node
@onready var mapIG: map = $map
@onready var player: CharacterBody3D = $Player
@onready var level: Node3D = $level
const FORREST_1 = preload("res://scenes/levels/forrest_1.tscn")
var toggleMap := false
var playerSpawn := false
var currScene : Node3D
var currRoom : Room
var act := 1

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("map"):
		toggleMap = !toggleMap
		if toggleMap:
			Events.emit_signal("showMap")
		else:
			Events.emit_signal("hideMap")
			

func _physics_process(delta: float) -> void:
	if playerSpawn:
		var startPos = currScene.get_node("playerSpawn").global_position
		player.global_position = startPos
		playerSpawn = false


func _ready() -> void:
	Events.mapExited.connect(moveToRoom)
	Events.battleWon.connect(battleWon)


func startRun() -> void:
	mapIG.generateNewMap()
	
	
func assignLevel(newLevel:PackedScene) -> void:
	if level.get_child_count() > 0:
		level.get_child(0).free()
		
	get_tree().paused = false
	var scene = newLevel.instantiate()
	level.add_child(scene)
	currScene = scene
	
	

func moveToRoom(room:Room) -> void:
	Events.hideMap.emit()
	toggleMap = !toggleMap
	if room.scene:
		assignLevel(room.scene)
		
	else:
		var type = room.type
		if type == Room.Type.MONSTER:
			assignLevel(FORREST_1)
			room.scene = FORREST_1
			
	if room.beaten == false:
		Events.spawnEnemies.emit()
	playerSpawn = true
	currRoom = room
	
func battleWon() -> void:
	currRoom.beaten = true
	mapIG.unlockNextRooms()
	
