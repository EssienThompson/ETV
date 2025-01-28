extends Node
@onready var mapIG: map = $map
@onready var player: CharacterBody3D = $Player
@onready var level: Node3D = $level
const TEST_LEVEL = preload("res://scenes/levels/test_level.tscn")
const TUT_COMBAT = preload("res://scenes/levels/tut/tutCombat.tscn")
const TUT_RELIC = preload("res://scenes/levels/tut/tutRelic.tscn")
const TUT_COMBAT_2 = preload("res://scenes/levels/tut/tutCombat2.tscn")
const TUT_COMBAT_3 = preload("res://scenes/levels/tut/tutCombat3.tscn")
const TUT_COMBAT_4 = preload("res://scenes/levels/tut/tutCombat4.tscn")
const FORREST_1 := preload("res://scenes/levels/act1/forrest_1.tscn")
const FORREST_2 := preload("res://scenes/levels/act1/forrest_2.tscn")
const FORREST_3 := preload("res://scenes/levels/act1/forrest_3.tscn")
const FORREST_4 := preload("res://scenes/levels/act1/forrest_4.tscn")
const ROCKY := preload("res://scenes/levels/act1/rocky.tscn")
const ROCKY_2 := preload("res://scenes/levels/act1/rocky_2.tscn")
const ROCKY_3 := preload("res://scenes/levels/act1/rocky_3.tscn")
var style: DialogicStyle = load("res://dialog/styleRelated/style.tres")
var WH_9_ITE: DialogicStyle = load("res://dialog/styleRelated/wh9ite.tres")

var tutPool := []
var act1Pool := []
var act1EliPool := []
var act1ReliPool := []
var activePool := []
var elitePool := []
var relicPool := []
var toggleMap := false
var playerSpawn := false
var currScene : Node3D 
var currRoom : Room
var focusedRoom : Room
var act := 1
var tutRoomCount := 0
var once := false
var variables = saveVariables.new()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("map") and player.isTalking == false:
		toggleMap = !toggleMap
		if toggleMap:
			Events.emit_signal("showMap")
			if currRoom:
				currRoom.focus = true
				focusedRoom = currRoom
			else:
				for i in range(0, mapIG.width):
					var room := mapIG.mapData[0][i] as Room
					if room.next_rooms.size() > 0:
						setRoomFocus(room)
						break
		else:
			Events.emit_signal("hideMap")
			
	var hpPer : float = player.currhp/player.maxhp
	if hpPer <= 0.4:
		Dialogic.VAR.player.health = "MWounded"
	elif hpPer <= 0.70:
		Dialogic.VAR.player.health = "wounded"
	elif hpPer <= 1:
		Dialogic.VAR.player.health = "healthy"
		
	if tutRoomCount == 5:
		Events.magiOpt = 1
		
	if Input.is_action_just_pressed("ui_up") && toggleMap: 
		if focusedRoom.row+1 <= mapIG.height-1:
			var row := focusedRoom.row+1
			var column := clampi(focusedRoom.column, 0, mapIG.width - 1)
			var left := clampi(column-1, 0, mapIG.width - 1)
			var right = clampi(column+1, 0, mapIG.width - 1)
			var hol := mapIG.mapData[row][column] as Room 
			var holLef := mapIG.mapData[row][left] as Room
			var holRi := mapIG.mapData[row][right] as Room
			
			if hol.next_rooms.size() > 0:
				setRoomFocus(hol)
			elif holLef.next_rooms.size() > 0:
				setRoomFocus(holLef)
			elif holRi.next_rooms.size() > 0:
				setRoomFocus(holRi)
				
	if Input.is_action_just_pressed("ui_down") && toggleMap: 
		if focusedRoom.row-1 >= 0:
			var row := focusedRoom.row-1
			var column := clampi(focusedRoom.column, 0, mapIG.width - 1)
			var left := clampi(column-1, 0, mapIG.width - 1)
			var right = clampi(column+1, 0, mapIG.width - 1)
			var hol := mapIG.mapData[row][column] as Room 
			var holLef := mapIG.mapData[row][left] as Room
			var holRi := mapIG.mapData[row][right] as Room
			
			if hol.next_rooms.size() > 0:
				setRoomFocus(hol)
			elif holLef.next_rooms.size() > 0:
				setRoomFocus(holLef)
			elif holRi.next_rooms.size() > 0:
				setRoomFocus(holRi)
				
	if Input.is_action_just_pressed("ui_right") && toggleMap: 
		if focusedRoom.column+1 <= mapIG.width-1:
			var col := focusedRoom.column+1
			for i in range(col, mapIG.width):
				var room := mapIG.mapData[focusedRoom.row][i] as Room
				if room.next_rooms.size() > 0:
					setRoomFocus(room)
					break
			
	if Input.is_action_just_pressed("ui_left") && toggleMap: 
		if focusedRoom.column-1 >= 0:
			var col := focusedRoom.column-1
			for i in range(col, -1, -1):
				var room := mapIG.mapData[focusedRoom.row][i] as Room
				if room.next_rooms.size() > 0:
					setRoomFocus(room)
					break
	
	if Input.is_action_just_pressed("ui_accept") && toggleMap:
		for mapRom:mapRoom in mapIG.rooms.get_children():
			if mapRom.room == focusedRoom && mapRom.available:
				mapRom.select()
		
	#var children := level.get_children()
	#for child in children:
		#if child.is_in_group("shadow"):
			#print(child.name)
			#var mat = child.material_override
			#mat.set_shader_parameter("position", player.global_transform.origin)
			
func setRoomFocus(room:Room):
	if room.type != Room.Type.NOT_ASSIGNED:
		if focusedRoom:
			focusedRoom.focus = false
		room.focus = true
		focusedRoom = room
		Events.focusCheck.emit()
		#print(focusedRoom.row, " ", focusedRoom.column)

func _physics_process(delta: float) -> void:
	if playerSpawn:
		if currScene != null:
			var startPos = currScene.get_node("playerSpawn")
			player.global_position = startPos.global_position
			player.global_rotation = startPos.global_rotation
			player.cam_root.zero()
			playerSpawn = false
			#print(variables.act1Map)
			
			


func _ready() -> void:
	Events.mapExited.connect(moveToRoom)
	Events.battleWon.connect(battleWon)
	Events.focusChanged.connect(setRoomFocus)
	Dialogic.signal_event.connect(dialogicSignals)
	Events.relicAdded.connect(saveRelics)
	playerSpawn = true

func startRun():
	currScene = $level/test_level
	runSetup()
	if act == 0:
		TutorialStart() #add sys to turn tut false after done once
		#print("tutor")
	else:
		genMap()
	copyToPool()
	copyToElitePool()
	copyToRelicPool()
	npcReady()
	variables.act = act
	#print(activePool)
	
func loadRun():#run for new save
	runSetup()
	variables = saveManager.loadVari()
	act = variables.act
	currRoom = variables.currRoom
	player.relic = variables.relic
	#load popups
	Events.loadRelicPopup(player)
	player.currhp = variables.playerCurrHp
	Events.loadRelics.emit()
	assignLevel(currRoom.scene)
	setCurrScene()
	loadMapData()
	mapIG.lastRoom = currRoom
	mapIG.generateLoadedMap()
	setRoomFocus(currRoom)
	#print(mapIG)
	copyToPool()
	copyToElitePool()
	

func genMap() -> void:
	mapIG.generateNewMap()
	mapIG.unlockFloor(0)
	
	
func TutorialStart() -> void:
	mapIG.generateTutorMap()
	mapIG.unlockFloor(0)
	act = 0
	
	
func runSetup() -> void:
	style.prepare()
	WH_9_ITE.prepare()
	
	
	tutPool.append(TUT_COMBAT)
	tutPool.append(TUT_RELIC)
	tutPool.append(TUT_COMBAT_2)
	tutPool.append(TUT_COMBAT_3)
	tutPool.append(TEST_LEVEL)
	tutPool.append(TUT_COMBAT_4)
	#tut add end
	
	
	act1Pool.append(FORREST_1)
	act1Pool.append(FORREST_2)
	act1Pool.append(FORREST_3)
	act1Pool.append(FORREST_4)
	act1Pool.append(ROCKY)
	act1Pool.append(ROCKY_2)
	act1Pool.append(ROCKY_3)
	
	act1EliPool.append(TUT_COMBAT_4)
	
	act1ReliPool.append(TUT_RELIC)

	
	
#func quitToMain() -> void:
	#Events.emit_signal("gameResumed")
	#get_tree().paused = false
	#get_tree().change_scene_to_file("res://scenes/menu&ui/StartMenu.tscn")
	
	
func assignLevel(newLevel:PackedScene) -> void:
	if level.get_child_count() > 0:
		level.get_child(0).free() #May or maynot cause problems 
		
	get_tree().paused = false
	var scene = newLevel.instantiate()
	level.add_child(scene)
	scene.act = act
	currScene = scene
	#npcReady()
	
	

func moveToRoom(room:Room) -> void:
	Events.hideMap.emit()
	
		
	if room.scene:
		assignLevel(room.scene)
		
	elif act == 0:
		assignLevel(activePool[tutRoomCount])
		room.scene = activePool[tutRoomCount]
		#currScene.tut = true
		tutRoomCount += 1
		
	else:
		var type = room.type
		if type == Room.Type.MONSTER: 
			var rando = randi_range(0, activePool.size() - 1)
			assignLevel(activePool[rando])
			room.scene = activePool[rando]
			activePool.erase(activePool[rando])
			if activePool.is_empty():
				copyToPool()
		
		elif type == Room.Type.REST:
			assignLevel(TEST_LEVEL)
			room.scene = TEST_LEVEL
			
		elif type == Room.Type.ELITE:
			var rando = randi_range(0, elitePool.size() - 1)
			assignLevel(elitePool[rando])
			room.scene = elitePool[rando]
			elitePool.erase(elitePool[rando])
			if elitePool.is_empty():
				copyToElitePool()
				
		elif type == Room.Type.TREASURE:
			var rando = randi_range(0, relicPool.size() - 1)
			assignLevel(relicPool[rando])
			room.scene = relicPool[rando]
			relicPool.erase(relicPool[rando])
			if relicPool.is_empty():
				copyToRelicPool()
			
	if room.beaten == false:
		Events.spawnEnemies.emit()
		toggleMap = !toggleMap
		
	else:
		mapIG.unlockNextRooms()
		mapIG.unlockBeatenRooms()
		
	playerSpawn = true
	currRoom = room
	variables.currRoom = currRoom
	#print(currRoom)
	
	
func battleWon() -> void:
	currRoom.beaten = true
	mapIG.unlockNextRooms()
	mapIG.unlockBeatenRooms()
	variables.playerCurrHp = player.currhp
	#move line to where new act's map is being created
	saveMapData()
	saveManager.saveVari(variables)
	#print(variables.mapData)
	#saveManager.mid_run_save()
	
func copyToPool() -> void:
	match act:
		1:
			activePool = act1Pool
			
func copyToElitePool() -> void:
	match act:
		1:
			elitePool = act1EliPool
			
func copyToRelicPool() -> void: #not way relic workkkkssssss
	match act:
		1:
			relicPool = act1ReliPool
			

func dialogicSignals(sig : String):
	if sig == "rockDrop":
		var chil = currScene.get_children()
		for child in chil:
			if child.is_in_group("interactable"):
				child.queue_free()
			if child.is_in_group("enemy"):
				child.currState = child.State.IDLE
				
			
func npcReady():
	var children = currScene.get_children()
	for child in children:
		if child.is_in_group("npc"):
			child.diaID = currScene.diaID
	
		
func setCurrScene():
	currScene = level.get_child(0)
	
func saveRelics():
	variables.relic = player.relic
	#load relpops
	saveManager.saveVari(variables)
	
	
func saveMapData():
	match act:
		1:
			variables.act1Map = mapIG.mapData
		2:
			variables.act2Map = mapIG.mapData
		3:
			variables.act3Map = mapIG.mapData
		4:
			variables.act4Map = mapIG.mapData
		5:
			variables.act5Map = mapIG.mapData
		
func loadMapData():
	match act:
		1:
			mapIG.mapData = variables.act1Map
		2:
			mapIG.mapData = variables.act2Map
		3:
			mapIG.mapData = variables.act3Map
		4:
			mapIG.mapData = variables.act4Map
		5:
			mapIG.mapData = variables.act5Map

	
