extends Node3D
const ZOMB = preload("res://scenes/enemyRelated/zomb.tscn")
var fightChecker := false
var timer := 0.0

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
	while timer <= 2:
		timer += delta
		for enemy in ene:
			enemy.velocity = Vector3.ZERO
	


func getAllMarkers() -> Array:
	return get_tree().get_nodes_in_group("enemySpawn")


func spawnEnemies() -> void:
	var spawnLoc = getAllMarkers()
	for spawn in spawnLoc:
		var enemy = ZOMB.instantiate()
		add_child(enemy)
		enemy.position = spawn.position
	fightChecker = true
