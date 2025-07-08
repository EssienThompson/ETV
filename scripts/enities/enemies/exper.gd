extends CharacterBody3D

@export var move_speed: float = 5.0
@export var turn_speed: float = 1.0
@onready var sword: Node3D = $sword
@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var lockOn: Node3D = $lockOn
#@onready var health_bar_3d: Node3D = $CollisionShape3D/HealthBar3D
#@onready var agroRange: Area3D = $agroRange
@onready var vision: Area3D = $vision
@onready var cube: MeshInstance3D = $sword/Cube
@onready var man: MeshInstance3D = $Armature/Skeleton3D/man

var target
var direction : Vector3
var damage := 25.0
var hurtType := 3
var postureDamage := 10.0
var team := 1.0
var maxHp := 1.0
var hp := 1.0
var posture := 1.0
var maxPosture := 1.0
var targetPos : Vector3
var distToTarget := 0.0
var timer := 0.0
var facing_angle : float 
var potentialTar : Array
var isAtking := false
var isParried := false
var dying := false
var losDecay := false
var rid_array : Array[RID] 
var navMap 

func _ready() -> void:
	rid_array.append(get_rid())

func _process(delta: float) -> void:
	#_handle_movement(delta)
	if hp <= 0:
		dying = true
		
	if dying:
		dissov(delta)
		
	navMap = get_world_3d().get_navigation_map()
	isAtking = sword.isAtking
		
	#sword.target = target
	if target:
		targetPos = target.global_transform.origin
		distToTarget = global_transform.origin.distance_to(targetPos)
		
	if losDecay:
		timer += delta
		if timer >= 5.0:
			target = null
			timer = 0.0
			losDecay = false
		
	#health_bar_3d.healthCurr(hp)
	#health_bar_3d.staggerCurr(posture)
	#if barVisible:
		#health_bar_3d.visible = true
	#else:
		#barTimer += delta
		#if barTimer >= 2:
			#health_bar_3d.visible = false
			#barTimer = 0
		
	
	
func _physics_process(delta: float) -> void:
	#var rot = facing_angle - global_rotation.y
	global_rotation.y = lerp_angle(global_rotation.y, facing_angle, 0.03)
	var origin = lockOn.global_position
	if !target: #so that if there is one we dont const switch
		for tar in potentialTar:
			var coll = checkLos(tar.global_position, origin)
			if coll != null && coll.is_in_group("player"):#coll.team != team
				target = tar
				
	if target:
		#if agroRange.overlaps_body(target):
			#var coll = checkLos(target.global_position, origin)
			#if coll != target:
				#print("not hit tar")
				#losDecay = true
			#else:
				#losDecay = false
				#timer = 0.0
		if vision.overlaps_body(target):
			var coll = checkLos(target.global_position, origin)
			if coll != target:
				losDecay = true
			else:
				losDecay = false
				timer = 0.0
		else:
			losDecay = true
		
	

func _handle_movement(delta):
	var dir = Input.get_axis('move_forward', 'move_back')
	translate(Vector3(0, 0, -dir) * move_speed * delta)
	
	var a_dir = Input.get_axis('move_right', 'move_left')
	rotate_object_local(Vector3.UP, a_dir * turn_speed * delta)
	
func attack():
	if isAtking == false:
		sword.startAttack()
	
	
func move(pos := Vector3.ZERO):
	if target == null:
		if navMap:
			var randPos = NavigationServer3D.map_get_closest_point(navMap, pos)
			nav.target_position = pos
			direction = (nav.get_next_path_position() - global_transform.origin).normalized()
			facing_angle = Vector2(direction.z, direction.x).angle()
	else:
		nav.target_position = targetPos
		direction = (nav.get_next_path_position() - global_transform.origin).normalized()
		facing_angle = Vector2(direction.z, direction.x).angle()
		
	velocity.x = direction.x * move_speed 
	velocity.z = direction.z * move_speed
	move_and_slide()
		
		
func runAway():
	var fleeVec = global_position - targetPos
	fleeVec = fleeVec.normalized() * randf_range(5.0, 10.0)
	var fleePoint = NavigationServer3D.map_get_closest_point(navMap, global_position + fleeVec)
	nav.target_position = fleePoint
	direction = (nav.get_next_path_position() - global_transform.origin).normalized()
	
	velocity.x = direction.x * (move_speed/1.5)
	velocity.z = direction.z * (move_speed/1.5)
	move_and_slide()
	
func parried():
	sword.startParry = true
	
func checkLos(targetPos, origin) -> Object:
	var space_state = get_world_3d().direct_space_state
	var enemyDir = (targetPos - origin).normalized()
	var distToEnemy = origin.distance_to(targetPos)
	var end = origin + enemyDir * distToEnemy
	var colliMask: int =  (1 << 0) | (1 << 4) | (1 << 5)
	var query = PhysicsRayQueryParameters3D.create(origin, end, colliMask)
	query.exclude = rid_array
	var result = space_state.intersect_ray(query)
	DrawLine3d.DrawLine(origin, end, Color(0, 1, 0), 2)
	var coll = result.get("collider")
	return coll
	
func isHit(hitInfo):
	var Entityteam = hitInfo[0]
	var damageDealt = hitInfo[1]
	#var postureRecieved = hitInfo[2]
	if team != Entityteam:
		hp = hp - damageDealt
		

func dissov(delta):
	var swordDis = cube.material_override as ShaderMaterial
	var manDis = man.material_override as ShaderMaterial
	var prog = manDis.get_shader_parameter("dissolveSlider")
	prog = lerpf(prog, 1.15, 0.6 * delta)
	#print(prog)
	manDis.set_shader_parameter("dissolveSlider", prog)
	swordDis.set_shader_parameter("dissolveSlider", prog)


func _on_vision_body_entered(body: Node3D) -> void:
	potentialTar.append(body)
	#print("entered ", body)
	
	
func _on_vision_body_exited(body: Node3D) -> void:
	if potentialTar.has(body):
		potentialTar.erase(body)
