extends Move
class_name jog

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
	
func update(input : InputPackage, delta : float):
	if not player.is_on_floor():
		player.velocity.y -= gravity * delta
		man.fallSword()
		
	var cam_rotate = camera.twist_pivot.rotation.y
	var direction = -(player.transform.basis * Vector3(input.input_direction.x, 0, input.input_direction.y)).normalized()
	direction = direction.rotated(Vector3.UP, cam_rotate)
	if direction:
		player.velocity.x = move_toward(player.velocity.x, direction.x * SPEED, ACCELERATION * delta)
		player.velocity.z = move_toward(player.velocity.z, direction.z * SPEED, ACCELERATION * delta)
		man.jogSword(direction)
		var facing_angle = Vector2(direction.z, direction.x).angle()
		man.rotation.y = lerp_angle(man.rotation.y, facing_angle, 0.25)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, ACCELERATION * delta)
		player.velocity.z = move_toward(player.velocity.z, 0, ACCELERATION * delta)
