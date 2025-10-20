extends Move
class_name idle

const ACCELERATION = 25.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func checkRelevance(input : InputPackage) -> String:
	input.actions.sort_custom(movesPrioritySort)
	return input.actions[0]
	
	#if input.actions.has("Jump"):
		#return "jump"
	#if input.input_direction != Vector2.ZERO:
		#return "run"
	#return "okay"
	
func update(input : InputPackage, delta : float):
	if not player.is_on_floor():
		player.velocity.y -= gravity * delta
		man.fallSword()
		
	player.velocity.x = move_toward(player.velocity.x, 0, ACCELERATION * delta)
	player.velocity.z = move_toward(player.velocity.z, 0, ACCELERATION * delta)
	man.idleSword()
