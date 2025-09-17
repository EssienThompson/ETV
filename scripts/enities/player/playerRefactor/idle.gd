extends Move
class_name idle

func checkRelevance(input : InputPackage) -> String:
	input.actions.sort_custom(movesPrioritySort)
	return input.actions[0]
	
	#if input.actions.has("Jump"):
		#return "jump"
	#if input.input_direction != Vector2.ZERO:
		#return "run"
	#return "okay"
