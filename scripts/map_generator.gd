class_name MapGenerator
extends Node

const X_DIST := 100
const Y_DIST := 150
const PLACEMENT_RANDOMNESS := 5
const FLOORS := 15
const TUT_FLOORS := 7
const MAP_WIDTH := 7
const TUT_WIDTH := 1
const PATHS := 6
const MONSTER_ROOM_WEIGHT := 10.0
const SHOP_ROOM_WEIGHT := 2.5
const REST_ROOM_WEIGHT := 4.0
const ELITE_ROOM_WEIGHT := 4.0

var random_room_type_weights = {
	Room.Type.MONSTER: 0.0,
	#Room.Type.REST: 0.0,
	Room.Type.ELITE: 0.0,
	Room.Type.SHOP: 0.0,
}
var randRoomTypeTotalWeight := 0
var mapData: Array[Array]
var hasShop := false


#func _ready() -> void:
	#generateMap()

func generateMap() -> Array[Array]:
	mapData = _genGrid()
	var startingPoints := _getRandStartingPoints()
	
	for j in startingPoints:
		var currJ := j
		for i in FLOORS - 1:
			currJ = _setupConnection(i, currJ)
	
	#print(mapData)
	_setupRest()
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
	
func generateTutor() -> Array[Array]:
	mapData = _genGrid(0)
	var startingPoints := _getRandStartingPoints(0)
	for j in startingPoints:
		var currJ := j
		for i in TUT_FLOORS - 1:
			currJ = _setupConnection(i, currJ, 0)

	_setupBossRoom(0)
	_setupTutorRoomTypes()
	
	return mapData
	
	
func _genGrid(mode : int = 1) -> Array[Array]:
	var result: Array[Array] = []
	var hei := 0
	var wid := 0
	
	if mode == 0:
		hei = TUT_FLOORS
		wid = TUT_WIDTH
	else:
		hei = FLOORS
		wid = MAP_WIDTH
		
		
	for i in hei:
		var adjRooms : Array[Room] = []
		
		for j in wid:
			var currRoom := Room.new()
			#currRoom.add_to_group("persist", true)
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

func _getRandStartingPoints(mode : int = 1) -> Array[int]:
	var yCoords: Array[int]
	var uniquePoints: int = 0
	var minPoint := 0
	if mode == 0:
		minPoint = 1
	else:
		minPoint = 2
	while uniquePoints < minPoint:
		uniquePoints = 0
		yCoords = []
		
		if mode == 1:
			for i in PATHS:
				var startingPoint := randi_range(0, MAP_WIDTH - 1)
				if not yCoords.has(startingPoint):
					uniquePoints += 1
					
				yCoords.append(startingPoint)
		elif mode == 0:
			var startingPoint := 0
			if not yCoords.has(startingPoint):
				uniquePoints += 1
					
			yCoords.append(startingPoint)
			
	return yCoords
	
	
	
func _setupConnection(i : int, j : int, mode : int = 1) -> int:
	var nextRoom : Room
	var currRoom := mapData[i][j] as Room
	var needed := true
	if mode == 0:
		needed = false
	
	while not nextRoom or _wouldCrossExistingPath(i, j, nextRoom, needed):
		var randJ := clampi(randi_range(j - 1, j + 1), 0, MAP_WIDTH - 1)
			
		if mode == 1:
			nextRoom = mapData[i + 1][randJ] 
		elif mode == 0:
			nextRoom = mapData[i + 1][0]
		
	currRoom.next_rooms.append((nextRoom))
	nextRoom.next_rooms.append((currRoom))
	
	return nextRoom.column
	
	
func _wouldCrossExistingPath(i:int, j:int, room:Room, needed:bool = true) -> bool:
	var leftNeighbour: Room
	var rightNeighbour: Room
	
	if !needed:
		return false
		
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
	
	
func _setupBossRoom(mode : int = 1) -> void:
	var middle := 0
	if mode == 0:
		middle = 0
	else: 
		middle = floori(MAP_WIDTH * 0.5)
		
	var bossRoom : Room
	
	if mode == 0:
		bossRoom = mapData[TUT_FLOORS - 1][middle] as Room
	else:
		bossRoom = mapData[FLOORS - 1][middle] as Room
	
	if mode == 1:
		for j in MAP_WIDTH:
			var currRoom = mapData[FLOORS - 2][j] as Room
			if currRoom.next_rooms:
				currRoom.next_rooms = [] as Array[Room]
				currRoom.next_rooms.append(bossRoom)
	elif mode == 0:
		var currRoom = mapData[TUT_FLOORS - 2][0] as Room
		if currRoom.next_rooms:
			currRoom.next_rooms = [] as Array[Room]
			currRoom.next_rooms.append(bossRoom)
			
	bossRoom.type = Room.Type.BOSS
	
	
func _setupRandRoomWeight() -> void:
	random_room_type_weights[Room.Type.MONSTER] = MONSTER_ROOM_WEIGHT
	random_room_type_weights[Room.Type.ELITE] = MONSTER_ROOM_WEIGHT + REST_ROOM_WEIGHT
	random_room_type_weights[Room.Type.SHOP] = MONSTER_ROOM_WEIGHT + REST_ROOM_WEIGHT + SHOP_ROOM_WEIGHT
	
	randRoomTypeTotalWeight = random_room_type_weights[Room.Type.SHOP]
	
	
func _setupRoomTypes() -> void:
	for room: Room in mapData[0]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.MONSTER
			
	for room: Room in mapData[8]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.TREASURE
	
	var middleW = floori(MAP_WIDTH * 0.5)
	var middleF = floori(FLOORS * 0.5)
	var restRoom := mapData[middleF][middleW] as Room
	restRoom.type = Room.Type.REST
			
	for currFloor in mapData:
		for room:Room in currFloor:
			for nextRoom:Room in room.next_rooms:
				if nextRoom.type == Room.Type.NOT_ASSIGNED:
					_setRandRoom(nextRoom)
					
	
func _setupTutorRoomTypes() -> void:
	for room: Room in mapData[0]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.MONSTER
			
	for room: Room in mapData[1]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.TREASURE
			
	for room: Room in mapData[2]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.MONSTER
			
	for room: Room in mapData[3]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.MONSTER
			
	for room: Room in mapData[4]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.REST
			
	for room: Room in mapData[5]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.ELITE
	
	
func _setRandRoom(roomSet:Room) -> void:
	var eliteBelow4 := true
	var consecutiveElite := true
	var shopBlow4 := true
	var alreadyShop := true
	#var restOn13 := true
	
	var typeCandid := Room.Type.NOT_ASSIGNED 
	
	while eliteBelow4 or shopBlow4 or consecutiveElite or alreadyShop:# or restOn13:
		typeCandid = _getRandRoomTypeByWeight()
		
		var isElite := typeCandid == Room.Type.ELITE
		var hasEliteParent := _roomHasParentOfType(roomSet, Room.Type.ELITE)
		var isShop := typeCandid == Room.Type.SHOP 
		#var hasShopParent := _roomHasParentOfType(roomSet, Room.Type.SHOP)
		
		eliteBelow4 = isElite and roomSet.row < 3
		consecutiveElite = isElite and hasEliteParent
		shopBlow4 = isShop and roomSet.row < 3
		alreadyShop = hasShop and isShop 
		#restOn13 = isElite and roomSet.row == 12
		
	if typeCandid == Room.Type.SHOP:
		hasShop = true
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
	
func _setupRest():
	var middleW = floori(MAP_WIDTH * 0.5)
	var middleF = floori(FLOORS * 0.5)
	var restRoom := mapData[middleF][middleW] as Room
	for i in range(middleW - 1, middleW + 1):
		var hol = mapData[middleF-1][i] as Room
		if hol.next_rooms.size() > 0 && !_wouldCrossExistingPath(middleF-1, i, restRoom):
			hol.next_rooms.append(restRoom)
			restRoom.next_rooms.append(hol)
	
	for i in range(middleF, FLOORS - 1):
		middleW = findPath(i, middleW)
		if middleW == -1:
			return
		
func findPath(i : int, j : int):
	var nextRoom : Room
	var currRoom := mapData[i][j] as Room
	var needed := true
	
	for num in range(j - 1, j + 1):
		num = clampi(num, 0, MAP_WIDTH - 1)
		nextRoom = mapData[i + 1][num]
		if nextRoom.next_rooms.size() > 0 && _wouldCrossExistingPath(i, num, nextRoom):
			if !currRoom.next_rooms.has(nextRoom):
				currRoom.next_rooms.append((nextRoom))
			if !nextRoom.next_rooms.has(currRoom):
				nextRoom.next_rooms.append((currRoom))
			needed = false
	if needed:
		while not nextRoom or _wouldCrossExistingPath(i, j, nextRoom):
			var randJ := clampi(randi_range(j - 1, j + 1), 0, MAP_WIDTH - 1)
				
			nextRoom = mapData[i + 1][randJ] 
			
		currRoom.next_rooms.append((nextRoom))
		nextRoom.next_rooms.append((currRoom))
		
		return nextRoom.column
	else:
		return -1
	
	
	
	
	
