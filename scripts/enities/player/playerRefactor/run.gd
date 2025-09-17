extends Move
class_name run

const SPEED = 5.0
const ACCELERATION = 25.0
const JUMP_VELOCITY = 7.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func checkRelevance(input : InputPackage) -> String:
	if input.actions.has("jump") and player.is_on_floor():
		return "jump"
	if input.input_direction == Vector2.ZERO:
		return "idle"
	return "okay"
