extends BTAction

func _tick(delta: float) -> Status:
	agent.runAway()
	return SUCCESS
