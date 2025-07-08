extends BTAction

func _tick(delta: float) -> Status:
	agent.queue_free()
	return SUCCESS
