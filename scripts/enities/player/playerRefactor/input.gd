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
	
	#if Input.is_action_pressed("parry"):
		#new_input.actions.append("parry")
	
	#if Input.is_action_pressed("roll"):
		#new_input.actions.append("roll")
	
	if Input.is_action_pressed("block"):
		new_input.actions.append("block")
	
	if Input.is_action_pressed("Jump"):
		if new_input.actions.has("sprint"):
			new_input.actions.append("jump_sprint")
		else:
			new_input.actions.append("jump")
	
	if Input.is_action_just_pressed("attack"):
		new_input.combat_actions.append("light_attack_pressed")
	#if Input.is_action_just_pressed("heavy_attack"):
		#new_input.combat_actions.append("heavy_attack_pressed")
	
	#print(new_input.input_direction)
	return new_input
