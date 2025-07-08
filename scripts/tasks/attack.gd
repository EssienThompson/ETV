extends BTAction

func _tick(delta: float) -> Status:
	agent.attack()
	return SUCCESS
