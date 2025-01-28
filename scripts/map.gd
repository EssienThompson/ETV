class_name map
extends Node2D

const SCROLL_SPEED := 50
const MAP_ROOM = preload("res://scenes/menu&ui/mapRoom.tscn")
const MAP_LINE = preload("res://scenes/menu&ui/mapLine.tscn")

@onready var map_generator: MapGenerator = %mapGenerator
@onready var lines: Node2D = %lines
@onready var rooms: Node2D = %rooms
@onready var visuals: Node2D = %visuals
@onready var camera_2d: Camera2D = %Camera2D
@onready var map_background: CanvasLayer = %mapBackground

var mapData: Array[Array]
var roomEntered: int
var lastRoom:Room
var cameraEdgeY: float
var reApp := false
var height := 0
var width := 0


func _ready() -> void:
	cameraEdgeY = MapGenerator.Y_DIST * (MapGenerator.FLOORS - 1)
	hideMap()
	Events.hideMap.connect(hideMap)
	Events.showMap.connect(showMap)
	Events.gamePaused.connect(mapPaused)
	Events.gameResumed.connect(mapResumed)
	#generateNewMap()
	#unlockFloor(0)
	


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("scroll_up"): #TODO make smoother for cont
		camera_2d.position.y -= SCROLL_SPEED
	if event.is_action_pressed("scroll_down"):
		camera_2d.position.y += SCROLL_SPEED
		
	camera_2d.position.y = clamp(camera_2d.position.y, -cameraEdgeY, 0)


func generateNewMap() -> void:
	roomEntered = 0
	mapData = map_generator.generateMap()
	height = mapData.size()
	width = mapData[0].size()
	createMap()
	
func generateLoadedMap():
	#mapData = data
	height = mapData.size()
	width = mapData[0].size()
	createMap()
	unlockNextRooms()
	unlockBeatenRooms()
	
func generateTutorMap() -> void:
	roomEntered = 0
	mapData = map_generator.generateTutor()
	height = mapData.size()
	width = mapData[0].size()
	createMap(0)
	
	
func createMap(mode : int = 1) -> void:
	for currFloor:Array in mapData:
		for room:Room in currFloor:
			if room.next_rooms.size() > 0:
				_spawnRoom(room)
				
	if mode == 1:
		var middle := floori(MapGenerator.MAP_WIDTH*0.5)
		_spawnRoom(mapData[MapGenerator.FLOORS-1][middle])
		
		var mapWidthPixels := MapGenerator.X_DIST * (MapGenerator.MAP_WIDTH - 1)
		visuals.position.x = (get_viewport_rect().size.x - mapWidthPixels) /2
		visuals.position.y = get_viewport_rect().size.y /2
		
	elif mode == 0:
		var middle := 0
		_spawnRoom(mapData[MapGenerator.TUT_FLOORS-1][middle])
		
		var mapWidthPixels := MapGenerator.X_DIST * (MapGenerator.TUT_WIDTH - 1)
		visuals.position.x = (get_viewport_rect().size.x - mapWidthPixels) /2
		visuals.position.y = get_viewport_rect().size.y /2
	

func unlockFloor(whichFloor:int = 0) -> void:
	for map_room:mapRoom in rooms.get_children():
		if map_room.room.row == whichFloor:
			map_room.available = true
			
			
func unlockNextRooms() -> void:
	for map_room:mapRoom in rooms.get_children():
		if lastRoom.next_rooms.has(map_room.room):
			map_room.available = true
			
func unlockBeatenRooms() -> void:
	for map_room:mapRoom in rooms.get_children():
		if map_room.room.beaten == true && map_room.room != lastRoom:
			#print(map_room.room.row, " ", map_room.room.column)
			map_room.available = true
			
func showMap() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	show()
	camera_2d.enabled = true
	map_background.visible = true
	
func hideMap() -> void: 
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hide()
	camera_2d.enabled = false
	map_background.visible = false
	
	
func mapPaused() -> void:
	if map_background.visible == true:
		reApp = true
	hideMap()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	
func mapResumed() -> void:
	if reApp:
		Events.showMap.emit()
		reApp = false
		
	
	
func _spawnRoom(room:Room) -> void:
	var newMapRoom := MAP_ROOM.instantiate() as mapRoom
	rooms.add_child(newMapRoom)
	newMapRoom.room = room
	newMapRoom.selected.connect(_onMapRoomSelected)
	_connectLines(room)
	
	if room.selected and room.row < roomEntered:
		newMapRoom.showSelected()
		
		
func _connectLines(room:Room) -> void:
	if room.next_rooms.is_empty():
		return
	if room.type == Room.Type.NOT_ASSIGNED:
		return
		
	for next:Room in room.next_rooms:
		if next != null:
			var newMapLine := MAP_LINE.instantiate() as Line2D
			newMapLine.add_point(room.position)
			newMapLine.add_point(next.position)
			lines.add_child(newMapLine)
		
		
func _onMapRoomSelected(room:Room) -> void: 
	for map_room: mapRoom in rooms.get_children():
		if map_room.room.row == room.row:
			#print(room.row)
			map_room.available = false
		map_room.available = false
		#map_room.room.selected = false
			
			
	lastRoom = room
	roomEntered += 1
	Events.mapExited.emit(room)
	

	
	
	
	
