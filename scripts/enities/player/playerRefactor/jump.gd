extends Move
class_name jump

const JUMP_VELOCITY = 7.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func checkRelevance(input : InputPackage) -> String:
	if player.is_on_floor():
		input.actions.sort_custom(movesPrioritySort)
		return input.actions[0]
	return "okay"
	
	#if player.is_on_floor():
		#if input.input_direction != Vector2.ZERO:
			#return "run"
		#return "idle"
	#return "okay"
	
func update(input : InputPackage, delta : float):
	player.velocity.y -= gravity * delta
	
func onEnterState():
	player.velocity.y += JUMP_VELOCITY
