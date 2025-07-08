extends BTAction

func _tick(delta: float) -> Status:
	var tarPos = blackboard.get_var("randPos")
	var currPos = agent.global_position
	
	agent.move(tarPos)
	
	if Vector2(currPos.x, currPos.z).distance_to(Vector2(tarPos.x, tarPos.z)) <= 0.1:
		agent.velocity = Vector3.ZERO
		return SUCCESS
	else:
		return RUNNING
