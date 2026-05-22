extends Move
class_name jump

const JUMP_VELOCITY = 7.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func checkRelevance(input : InputPackage) -> String:
	if player.is_on_floor():
		input.actions.sort_custom(movesPrioritySort)
		return input.actions[0]
	return "okay"
	
	
func update(input : InputPackage, delta : float):
	player.velocity.y -= gravity * delta
	man.fallSword()
	
func onEnterState():
	player.velocity.y += JUMP_VELOCITY
	man.jumpSword()
