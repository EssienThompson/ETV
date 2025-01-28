extends Node3D
const ZOMB = preload("res://scenes/enemyRelated/zomb.tscn")
const DOG = preload("res://scenes/enemyRelated/dog.tscn")
const ELI_ZOMB = preload("res://scenes/enemyRelated/eli-zomb.tscn")
var fightChecker := false
var tutElite := false
var timer := 0.0
@export var mode := 0
@export var diaID : String
var act := 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.spawnEnemies.connect(spawnEnemies)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if fightChecker:
		var ene := get_tree().get_nodes_in_group("enemy")
		if ene.is_empty():
			Events.battleWon.emit()
			fightChecker = false
			
	var ene := get_tree().get_nodes_in_group("enemy")
	if timer <= 1.5:
		timer += delta
		for enemy in ene:
			enemy.velocity = Vector3.ZERO
		if tutElite:
			eliNerf()
	


func getAllMarkers() -> Array:
	return get_tree().get_nodes_in_group("enemySpawn")
	
	
func eliNerf():
	var ene := get_tree().get_nodes_in_group("enemy")
	for my in ene:
		my.hp = 300
		my.currState = my.State.IDLE


func spawnEnemies() -> void:
	var spawnLoc = getAllMarkers()
	var player = get_node("playerSpawn")
	for spawn in spawnLoc:
		var rand = randi_range(1, 2)
		var enemy
		if mode == 0:
			enemy = ZOMB.instantiate()
		elif mode == 1:
			if rand == 1:
				enemy = ZOMB.instantiate()
			else:
				enemy = DOG.instantiate()
		elif mode == 2:
			enemy = DOG.instantiate()
		elif mode == 3:
			enemy = ELI_ZOMB.instantiate()
				
		add_child(enemy)
		enemy.position = spawn.position
		enemy.rotation = spawn.rotation
		enemy.look_at(player.global_position)
		if mode == 3 && act == 0:
			tutElite = true
		
	fightChecker = true
	
	if (name == "tutRelic" or "tutCombat4") && act != 0:
		var npc := get_tree().get_nodes_in_group("npc")
		for magi in npc:
			if magi.name == "magision":
				magi.queue_free()
