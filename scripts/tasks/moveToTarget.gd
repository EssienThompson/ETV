extends BTAction

func _tick(delta: float) -> Status:
	blackboard.set_var("distToTarget", agent.distToTarget)
	if agent.target == null:
		return FAILURE
	else:
		agent.move()
		return SUCCESS
	
	
