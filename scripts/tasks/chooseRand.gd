extends BTAction

func _tick(delta: float) -> Status:
	var startPos = agent.global_position
	var randomDir = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	var randPoint = startPos + randomDir * 5
	
	#var randPos = NavigationServer3D.map_get_closest_point(agent.get_world_3d().navigation_map, randPoint)
	
	blackboard.set_var("randPos", randPoint)
	
	return SUCCESS
