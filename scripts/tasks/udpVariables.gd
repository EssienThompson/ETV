extends BTAction

func _tick(delta: float) -> Status:
	blackboard.set_var("target", agent.target)
	blackboard.set_var("distToTarget", agent.distToTarget)
	blackboard.set_var("isAtking", agent.isAtking)
	blackboard.set_var("dying", agent.dying)
	return SUCCESS
