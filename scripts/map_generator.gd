class_name MapGenerator
extends Node

const X_DIST := 100
const Y_DIST := 150
const PLACEMENT_RANDOMNESS := 5
const FLOORS := 15
const MAP_WIDTH := 7
const PATHS := 6
const MONSTER_ROOM_WEIGHT := 10.0
const SHOP_ROOM_WEIGHT := 2.5
const REST_ROOM_WEIGHT := 4.0

var random_room_type_weights = {
	Room.Type.MONSTER: 0.0,
	Room.Type.REST: 0.0,
	Room.Type.SHOP: 0.0
}
var randRoomTypeTotalWeight := 0
var mapData: Array[Array]

#func _ready() -> void:
	#generateMap()

func generateMap() -> Array[Array]:
	mapData = _genGrid()
	var startingPoints := _getRandStartingPoints()
	
	for j in startingPoints:
		var currJ := j
		for i in FLOORS - 1:
			currJ = _setupConnection(i, currJ)
	
	_setupBossRoom()
	_setupRandRoomWeight()
	_setupRoomTypes()
	
	#var i := 0
	#for floor in mapData:
		#print("floor %s" % i)
		#var usedRooms = floor.filter(
			#func(room:Room): return room.next_rooms.size() > 0
		#)
		#print(usedRooms)
		#i += 1
	
	return mapData
	
	
func _genGrid() -> Array[Array]:
	var result: Array[Array] = []
	
	for i in FLOORS:
		var adjRooms : Array[Room] = []
		
		for j in MAP_WIDTH:
			var currRoom := Room.new()
			var offset := Vector2(randf(), randf()) * PLACEMENT_RANDOMNESS
			currRoom.position = Vector2(j * X_DIST, i * -Y_DIST) + offset
			currRoom.row = i
			currRoom.column = j
			currRoom.next_rooms = []
			
			if i == FLOORS - 1:
				currRoom.position.y = (i + 1) * -Y_DIST
				
			adjRooms.append(currRoom)
			
		result.append(adjRooms)
			
	return result

func _getRandStartingPoints() -> Array[int]:
	var yCoords: Array[int]
	var uniquePoints: int = 0
	
	while uniquePoints < 2:
		uniquePoints = 0
		yCoords = []
		
		for i in PATHS:
			var startingPoint := randi_range(0, MAP_WIDTH - 1)
			if not yCoords.has(startingPoint):
				uniquePoints += 1
				
			yCoords.append(startingPoint)
			
	return yCoords
	
	
	
func _setupConnection(i : int, j : int) -> int:
	var nextRoom : Room
	var currRoom := mapData[i][j] as Room
	while not nextRoom or _wouldCrossExistingPath(i, j, nextRoom):
		var randJ := clampi(randi_range(j - 1, j + 1), 0, MAP_WIDTH - 1)
		nextRoom = mapData[i + 1][randJ] #TODO <<<<<<<<<<
		
	currRoom.next_rooms.append((nextRoom))
	
	return nextRoom.column
	
	
func _wouldCrossExistingPath(i:int, j:int, room:Room) -> bool:
	var leftNeighbour: Room
	var rightNeighbour: Room
	
	if j > 0:
		leftNeighbour = mapData[i][j-1]
		
	if j < MAP_WIDTH - 1:
		rightNeighbour = mapData[i][j+1]
		
	if rightNeighbour and room.column > j:
		for nextRoom: Room in rightNeighbour.next_rooms:
			if nextRoom.column < room.column:
				return true
				
	if leftNeighbour and room.column < j:
		for nextRoom: Room in leftNeighbour.next_rooms:
			if nextRoom.column > room.column:
				return true
				
	return false
	
	
func _setupBossRoom() -> void:
	var middle := floori(MAP_WIDTH * 0.5)
	var bossRoom := mapData[FLOORS - 1][middle] as Room
	
	for j in MAP_WIDTH:
		var currRoom = mapData[FLOORS - 2][j] as Room
		if currRoom.next_rooms:
			currRoom.next_rooms = [] as Array[Room]
			currRoom.next_rooms.append(bossRoom)
			
	bossRoom.type = Room.Type.BOSS
	
	
func _setupRandRoomWeight() -> void:
	random_room_type_weights[Room.Type.MONSTER] = MONSTER_ROOM_WEIGHT
	random_room_type_weights[Room.Type.REST] = MONSTER_ROOM_WEIGHT + REST_ROOM_WEIGHT
	random_room_type_weights[Room.Type.SHOP] = MONSTER_ROOM_WEIGHT + REST_ROOM_WEIGHT + SHOP_ROOM_WEIGHT
	
	randRoomTypeTotalWeight = random_room_type_weights[Room.Type.SHOP]
	
func _setupRoomTypes() -> void:
	for room: Room in mapData[0]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.MONSTER
			
	for room: Room in mapData[8]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.TREASURE
			
	for room: Room in mapData[13]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.REST
			
	for currFloor in mapData:
		for room:Room in currFloor:
			for nextRoom:Room in room.next_rooms:
				if nextRoom.type == Room.Type.NOT_ASSIGNED:
					_setRandRoom(nextRoom)
	
	
func _setRandRoom(roomSet:Room) -> void:
	var restBelow4 := true
	var consecutiveRest := true
	var consecShop := true
	var restOn13 := true
	
	var typeCandid := Room.Type.NOT_ASSIGNED # KEEP IN MIND, was room.type (seems fine after running)
	
	while restBelow4 or consecShop or consecutiveRest or restOn13:
		typeCandid = _getRandRoomTypeByWeight()
		
		var isRest := typeCandid == Room.Type.REST
		var hasRestParent := _roomHasParentOfType(roomSet, Room.Type.REST)
		var isShop := typeCandid == Room.Type.SHOP
		var hasShopParent := _roomHasParentOfType(roomSet, Room.Type.SHOP)
		
		restBelow4 = isRest and roomSet.row < 3
		consecutiveRest = isRest and hasRestParent
		consecShop = isShop and hasShopParent
		restOn13 = isRest and roomSet.row == 12
		
	roomSet.type = typeCandid 
	
	
func _roomHasParentOfType(room: Room, type: Room.Type) -> bool:
	var parents: Array[Room] = []
	
	if room.column > 0 and room.row > 0:
		var parentCandid := mapData[room.row - 1][room.column - 1] as Room
		if parentCandid.next_rooms.has(room):
			parents.append(parentCandid)
	
	if room.row > 0:
		var parentCandid := mapData[room.row - 1][room.column] as Room
		if parentCandid.next_rooms.has(room):
			parents.append(parentCandid)
			
	if room.column < MAP_WIDTH-1 and room.row > 0:
		var parentCandid := mapData[room.row - 1][room.column + 1] as Room
		if parentCandid.next_rooms.has(room):
			parents.append(parentCandid)
			
	for parent:Room in parents:
		if parent.type == type:
			return true
			
	return false
	
func _getRandRoomTypeByWeight():
	var roll := randf_range(0.0, randRoomTypeTotalWeight)
	
	for type:Room.Type in random_room_type_weights:
		if random_room_type_weights[type] > roll:
			return type
			
	return Room.Type.MONSTER
	
	
	
	
