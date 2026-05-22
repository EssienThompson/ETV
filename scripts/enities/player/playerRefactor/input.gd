extends Node
class_name InputGatherer

func gather_input() -> InputPackage:
	var new_input = InputPackage.new()
	
	new_input.actions.append("idle")
	
	new_input.input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if new_input.input_direction != Vector2.ZERO:
		new_input.actions.append("jog")
		if Input.is_action_pressed("sprint"):		# sprint is hidden here to avoid standing in place and sprinting
			new_input.actions.append("sprint")
	
	if Input.is_action_pressed("Jump"):
		new_input.actions.append("jump")
	
	return new_input
