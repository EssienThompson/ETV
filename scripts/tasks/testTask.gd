extends BTAction

func _tick(delta: float) -> Status:
	var dist = blackboard.get_var("target")
	print(dist)
	return SUCCESS
