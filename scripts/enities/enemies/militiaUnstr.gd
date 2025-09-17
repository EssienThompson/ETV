extends CharacterBody3D
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var animation_tree: AnimationTree = $AnimationPlayer/AnimationTree
@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var hurtbo: hurtbox = $hurtbox
@onready var hitbo: hitbox = $rig/Skeleton3D/spear/hitbox
@onready var spear: MeshInstance3D = $rig/Skeleton3D/spear/spear
@onready var mask: MeshInstance3D = $rig/Skeleton3D/mask/mask
@onready var eyes: MeshInstance3D = $rig/Skeleton3D/eyes/eyes
@onready var mouth: MeshInstance3D = $rig/Skeleton3D/mouth/mouth
@onready var bracer: MeshInstance3D = $rig/Skeleton3D/bracer
@onready var helm: MeshInstance3D = $rig/Skeleton3D/helm
@onready var left_glove: MeshInstance3D = $rig/Skeleton3D/leftGlove
@onready var man: MeshInstance3D = $rig/Skeleton3D/man
@onready var skirt: MeshInstance3D = $rig/Skeleton3D/skirt
@onready var tunic: MeshInstance3D = $rig/Skeleton3D/tunic
@onready var tunic_plate: MeshInstance3D = $rig/Skeleton3D/tunicPlate
@onready var health_bar_3d: Node3D = $CollisionShape3D/HealthBar3D
@onready var rig: Node3D = $rig
@onready var lockOn: Node3D = $lockOn
@onready var aggro_range: Area3D = $rig/aggroRange
@onready var vision: Area3D = $rig/vision

const SPEED = 7 #7
const ACCELERATION = 45
enum State {
	IDLE,
	CHASE,
	HURT,
	ATTACK,
	STAGGERED,
	BLOCK,
	BLOCKHIT,
	DEATH,
	GUARD, #non atk idle
	SEARCHING, #look for target after reaching alert position
	PARRY, #active for parrying
	PARRYHIT,
	FEINT, #active for feint
	FEINTHIT,
	DEFLECTED, # got parried
}
var currState : State = State.IDLE
var target
var team := 2
var damage := 0
var postureDamage := 0 
var hurtType := 0
var hp := 200.0
var maxHp := 200.0
var posture := 60.0
var maxPosture := 60.0 
var blockBlendVal := 0.0
var parryBlendVal := 0.0
var staggerBlendVal := 0.0
var currDisolv := 0.0

var direction := Vector3.ZERO
var targetPos := Vector3.ZERO
var atkDir:= Vector3.ZERO
var attackerDir := Vector3.ZERO
var facing_angle : float
var angle : float
var hoverRadius := 7.5
var timer := 0.0
var timerThresh := 0.0
var facingThresh := 0.0
var rando := 0.0
var staggerTimer := 0.0
var barTimer := 0.0
var deathTimer := 0.0
var postureTimer := 0.0
var postLowTimer := 0.0
var blockHitCount := 0
var blockHitTimer := 0.0
var groupTactic := false
var leftFlank := 0
var rightFlank := 0
var deflectCount := 0
var sameTargetGroup = []
var unfeintable = []
var midRange := false
var veloZero := false
var atkMove := false
var isAtking := false
var isBlocking := false
var blockEndAni := false
var blockRepeat := false
var once := false
var rotati := false
var dying := false
var barVisible := false
var postLower := false
var left := false
var right := false
var groupCancel := false
var parryTriggered := false
var isFeinting := false
var alert := false
var alertPos := Vector3.ZERO
var searchPos := Vector3.ZERO
var searchTimer := 0
var searchMoving := false
var hitStunned := false
var stunTimer := 0.0
var isMoving := false
var startBlocking := false
var isStagger := false
var isParrying := false
var gotParried := false

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if isMoving or (isBlocking && groupTactic):
		var velo = velocity.move_toward(direction * SPEED, ACCELERATION*delta)
		nav.set_velocity(velo)
	elif atkMove:
		velocity = velocity.move_toward(atkDir * SPEED, ACCELERATION*delta)
	elif hitStunned:
		velocity.x = -attackerDir.x * SPEED/2
		velocity.z = -attackerDir.z * SPEED/2
	else:
		velocity.x = 0
		velocity.z = 0
		
	move_and_slide()
	var rot
	#if rotati == true:
	rot = facing_angle - global_rotation.y
	rig.rotation.y = lerp_angle(rig.rotation.y, rot, 0.08)
	#else:
		#rig.rotation.y = lerp_angle(rig.rotation.y, facing_angle, 0.08)
	
func _process(delta):
	if barVisible == true:
		health_bar_3d.visible = true
	else:
		barTimer += delta
		if barTimer >= 2:
			health_bar_3d.visible = false
			barTimer = 0
		
	if postureTimer <= 2 && postLower == false:
		postureTimer += delta
	else:
		if posture < maxPosture:
			postLower = true
		else:
			postLower = false
		
	if postLower:
		postLowTimer += delta
		if postLowTimer >= 0.1:
			posture = posture + (maxPosture*0.01)
			postLowTimer = 0.0
			if posture >= maxPosture:
				posture = maxPosture
	
	if posture <= 0:
		currState = State.STAGGERED
		
	if hp <= 0:
		currState = State.DEATH 
		#man.death = true
		dying = true
		
	for tar in unfeintable:
		if !tar.is_inside_tree() or tar == null:
			unfeintable.erase(tar)
		elif "dying" in tar:
			if dying == true:
				unfeintable.erase(tar)
				
	if target != null and target.is_inside_tree():
		checkValidTarget()
		 
	if isAtking:
		atkLogic(delta)
			
	if startBlocking:
		blockLogic(delta)
			
	if isStagger:
		staggerTimer += delta
		if staggerTimer >= 0.25:
			var t = min(staggerTimer/2.75, 1.0)
			var hol = 1-t
			setStaggerBlend(hol)
		if staggerTimer >= 3:
			unStagger()
			posture = 0
			staggerTimer = 0
			interrupt()
			isStagger = false
				
				
	if hitStunned:
		stunTimer += delta
		if stunTimer <= 0.25:#stun time
			interrupt()
			velocity.x = (-attackerDir.x * SPEED)/2
			velocity.z = (-attackerDir.z * SPEED)/2
		else:
			stunTimer = 0
			hitStunned = false
				
	if dying: 
		deathTimer += delta
		dissolve(deathTimer)
		if deathTimer >= 2.5:
			queue_free()
			
		if sameTargetGroup:
			for guard in sameTargetGroup:
				guard.sameTargetGroup.erase(self)
				sameTargetGroup.erase(guard)
					
				
			
		
	if blockEndAni:
		if blockBlendVal <= 0.001: 
			blockEndAni = false
		blockEnd()
		isBlocking = false

func _ready():
	#detectArea.connect("body_entered", Callable(self, "_on_Body_Entered"))
	#detectArea.connect("body_exited", Callable(self, "_on_Body_Exited"))
	Events.militiaAlert.connect(runToAlert)
	hp = maxHp
	health_bar_3d.setStaggerMax(maxPosture)
	health_bar_3d.setHealthMax(maxHp)
	health_bar_3d.fullBar()
	health_bar_3d.healthCurr(hp)
	health_bar_3d.staggerCurr(posture)
	health_bar_3d.staggerColor()
	
func isHit(hitInfo):
	var Entityteam = hitInfo[0]
	var damageDealt = hitInfo[1]
	var postureRecieved = hitInfo[2]
	var entityHurtType = hitInfo[3]
	var entityOrigin = hitInfo[4]
	var entity = hitInfo[5]
	velocity.x = 0
	velocity.z = 0
	if team != Entityteam:
		abortOneshots()
		if isParrying:
			performAtk("parry")
		match currState:
			State.CHASE:
				hurtAni(entityHurtType)
				currState = State.HURT
				hp = hp - damageDealt
			State.IDLE:
				hurtAni(entityHurtType)
				currState = State.HURT
				hp = hp - damageDealt
			State.HURT: 
				hurtAni(entityHurtType)
				currState = State.HURT
				hp = hp - damageDealt
			State.ATTACK:
				atkAbort()
				hurtAni(entityHurtType)
				currState = State.HURT
				hp = hp - damageDealt
			State.STAGGERED:
				hp = hp - (damageDealt * 2)
			State.BLOCK:
				blockHitCount += 1
				#timer -= 0.25
				blockHit1()
				posture = posture - postureRecieved
				leaveGroupTactic()
				currState = State.BLOCKHIT
				#sparksActi() #on block
			State.BLOCKHIT:
				blockHit1()
				posture = posture - postureRecieved
				currState = State.BLOCKHIT
				
			State.PARRY:
				parryHit()
				Events.hitstop(0.05, 0.3)
				timer = 0
				parryTriggered = true
				
		health_bar_3d.healthCurr(hp)
		health_bar_3d.staggerCurr(posture)
		health_bar_3d.staggerColor()
		attackerDir = (entityOrigin - global_transform.origin).normalized()
		facing_angle = Vector2(attackerDir.z, attackerDir.x).angle()
		barVisible = true
		postureTimer = 0
		
		if entity != null and entity.is_inside_tree():
			target = entity
			#print("target set via hit")
			Events.militiaSuspects.append(entity)
			Events.militiaAlert.emit(global_position)
		

func interrupt():
	isAtking = false
	isBlocking = false
	isFeinting = false
	timerThresh = 0
	facingThresh = 0
	timer = 0

func performAtk(type:String):
	match type:
		"atk":
			atk1()
			timerThresh = 0.8
			facingThresh = 0.4
			damage = 20
			postureDamage = 20
			hurtType = 3
			isAtking = true
			
		"parry":
			parry()
		
		"feint":
			feint()
			timerThresh = 2
			facingThresh = 2
			isFeinting = true
		
		"feintPunish":
			feintAbort()
			feintPunish()
			timerThresh = 0.4
			facingThresh = 0.0
			damage = 10
			postureDamage = 40
			hurtType = 4
			isAtking = true
			atkDir = (targetPos - global_transform.origin).normalized() #once off cause feint has no turning time
		

	
		
func hurtAni(ht):
	if ht == 1:
		hit1()
	elif ht == 2:
		hit2()
	elif ht == 3:
		hit3()
	elif ht == 4 or ht == 5:
		hit4()
		
func sameTargetGuardCheck(guard, otherTarget):
	if otherTarget == target:
		groupTactic = true
		guard.groupTactic = true
		sameTargetGroup.append(guard)
		guard.sameTargetGroup.append(self)
	elif guard in sameTargetGroup:
		sameTargetGroup.erase(guard)
		if sameTargetGroup.size() == 0:
			groupTactic = false
		# maybe something missing idk
		
func leaveGroupTactic():
	if right:
		right = false
		rightFlank -= 1
		for guard in sameTargetGroup:
			guard.rightFlank += 1 
	elif left:
		left = false
		leftFlank -= 1
		for guard in sameTargetGroup:
			guard.leftFlank += 1 
			
	groupCancel = false
	
func parried():
	atkAbort()
	if deflectCount == 0:
		hitDeflected1()
		deflectCount = 1
	elif deflectCount == 1:
		hitDeflected2()
		deflectCount = 0
	
	postureTimer = 0
	postLower = false
	posture = posture - 20
	
	
func runToAlert(alertPosition):
	if (target == null or !target.is_inside_tree()):
		var distToAlert := global_transform.origin.distance_to(alertPosition)
		if distToAlert < 60.0: #60m to hear alerts
			# for circle
			#var randAngle = randf() * 2 * PI
			#var randDistance = sqrt(randf() * 7.5)#float is the radius
			#var offsetX = cos(randAngle) * randDistance
			#var offsetZ = sin(randAngle) * randDistance 
			
			# for square
			var width = 7.5
			var depth = 7.5
			var offsetX = randf_range(-width/2, width/2)
			var offsetZ = randf_range(-depth/2, depth/2)
			
			var randomPos = alertPosition + Vector3(offsetX, alertPosition.y, offsetZ)
			nav.target_position = randomPos
			await get_tree().process_frame
			var validPoint = nav.get_next_path_position()
			if validPoint != Vector3.ZERO:
				currState = State.CHASE
				alertPos = randomPos 
				alert = true
				print("alert via signal")
			else:
				runToAlert(alertPosition) # recur to try get a valid point
			
func getSearchPosition():
	var width = 7.5
	var depth = 7.5
	var offsetX = randf_range(-width/2, width/2)
	var offsetZ = randf_range(-depth/2, depth/2)
	var randomPos = global_position + Vector3(offsetX, global_position.y, offsetZ)
	searchPos = randomPos
		
func dissolve(deathTimer):
	eyes.visible = false
	mouth.visible = false
	var t = min(deathTimer/2.0, 1.0)
	var prog = lerpf(currDisolv, 1.15, t)
	spear.changeDisolveVal(prog)
	mask.changeDisolveVal(prog)
	man.changeDisolveVal(prog)
	bracer.changeDisolveVal(prog)
	helm.changeDisolveVal(prog)
	left_glove.changeDisolveVal(prog)
	skirt.changeDisolveVal(prog)
	tunic.changeDisolveVal(prog)
	tunic_plate.changeDisolveVal(prog)
	
func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z
	
	
	
func checkLos(targetPos, origin) -> Object:
	var space_state = get_world_3d().direct_space_state
	var enemyDir = (targetPos - origin).normalized()
	var distToEnemy = origin.distance_to(targetPos)
	var end = origin + enemyDir * distToEnemy
	var colliMask: int =  (1 << 0) | (1 << 4) | (1 << 5)
	var query = PhysicsRayQueryParameters3D.create(origin, end, colliMask)
	var rid_array = []
	rid_array.append(get_rid())
	query.exclude = rid_array
	var result = space_state.intersect_ray(query)
	#DrawLine3d.DrawLine(origin, end, Color(0, 1, 0), 2)
	var coll = result.get("collider")
	return coll

func _on_vision_body_entered(body: Node3D) -> void:
	if (target == null or !target.is_inside_tree()): #body in Events.militiaSuspects (removed for testing) TODO
		var coll = checkLos(body.global_position, vision.global_position)
		if coll == body:
			#rotati = true
			target = body
			#print("target vis vision")
			alert = false
			currState = State.CHASE
		
func targetOutOfLos():
	alert = true
	#print("alert via los")
	alertPos = target.global_position
	target = null
	currState = State.CHASE
	
func checkValidTarget():
	var tarPos
	if "lockOn" in target:
		tarPos = target.lockOn.global_position
	else:
		tarPos = target.global_position
	var losObj = checkLos(tarPos, vision.global_position)
	#var distToTar = global_transform.origin.distance_to(target.global_position)
	var overlapBodies = vision.get_overlapping_bodies()
	var overlap = false
	for body in overlapBodies:
		if body == target:
			overlap = true
			
	var aggroBodies = aggro_range.get_overlapping_bodies()
	var aggro = false
	for body in aggroBodies:
		if body == target:
			aggro = true
			
	if (!aggro && !overlap) or losObj != target:
		#print("tar lost")
		#if !aggro:
			#print("aggro lsot")
		#if !overlap:
			#print("out of sight")
		#if losObj != target:
			#print("no los")
		targetOutOfLos()

func moveToPosition(pos:Vector3):
	isMoving = true
	var jogVector := Vector2(0, 1)
	if !isBlocking:
		jog(jogVector)
		jogScale(1.0)
	elif groupTactic && !groupCancel:
		jog(jogVector)
		jogScale(0.6)
	nav.target_position = pos
	direction = (nav.get_next_path_position() - global_transform.origin).normalized()
	facing_angle = Vector2(direction.z, direction.x).angle() ##IS IN VELO COMPUTED

func blockFlank(delta):
	targetPos = target.global_transform.origin
	angle = wrapf(angle, 0, PI * 2)  # Keep the angle within the range [0, 2π]
	var x = hoverRadius * cos(angle)
	var z = hoverRadius * sin(angle)
	var new_position = targetPos + Vector3(x, 0, z)
	moveToPosition(new_position)
	
	var jogVector = (Vector2(direction.x, direction.z)).normalized()
	if leftFlank == rightFlank:
		var rand = randi_range(1, 2)
		if rand == 1:
			leftFlank += 1
			left = true
			for guard in sameTargetGroup:
				guard.leftFlank += 1 
		else:
			rightFlank += 1
			right = true
			for guard in sameTargetGroup:
				guard.rightFlank += 1 
	elif leftFlank > rightFlank:
		rightFlank += 1
		right = true
		for guard in sameTargetGroup:
			guard.rightFlank += 1 
	else:
		leftFlank += 1
		left = true
		for guard in sameTargetGroup:
			guard.leftFlank += 1 
				
	if right:
		angle -= SPEED/1.5 * delta/hoverRadius  
	elif left:
		angle += SPEED/1.5 * delta/hoverRadius 
	

func atkLogic(delta):
	targetPos = target.global_transform.origin
	var distToTar = global_transform.origin.distance_to(targetPos)
	direction = (targetPos - global_transform.origin).normalized()
	timer += delta
	if distToTar <= 3.3:
		veloZero = true
		midRange = false
	elif distToTar <= 7.5:
		veloZero = false
		midRange = true
	elif timer >= timerThresh:
		midRange = false
		atkAbort()
	
		
	if timer >= timerThresh && isAtking:
		timer = 0
		timerThresh = 0
		facingThresh = 0
		rando = 0
		isAtking = false
		blockRepeat = false
		
	if timer <= facingThresh:
		facing_angle = Vector2(direction.z, direction.x).angle()
		atkDir = direction
		
	if timer >= facingThresh:
		atkMove = true
		if midRange:
			veloZero = false
	else: 
		atkMove = false
		if midRange:
			veloZero = true
			
func blockLogic(delta):
	block()
	timer += delta
	isBlocking = true
	blockEndAni = false
	
	if groupTactic and !groupCancel:
		blockFlank(delta)
	else:
		battleIdle() 
			
	
	if blockRepeat == true:
		currState = State.CHASE
		blockEndAni = true
		leaveGroupTactic()
				
	var distToTar = global_transform.origin.distance_to(targetPos)
	var targetDirection = (targetPos - global_transform.origin).normalized()
	
	if distToTar >= 5.5 && timer >= 1.0:
		currState = State.CHASE 
		blockHitCount = 0
		blockRepeat = true
		timer = 0
		blockEndAni = true
		leaveGroupTactic()
	if timer >= 2.5:
		var rand = randi_range(1, 3)# 1 in 3
		if rand == 1:
			currState = State.PARRY
		else:
			currState = State.CHASE
		blockHitCount = 0
		blockRepeat = true
		timer = 0
		blockEndAni = true
		leaveGroupTactic()
		
	facing_angle = Vector2(targetDirection.z, targetDirection.x).angle()

func jog(jogVector):
	animation_tree.set("parameters/JogSpace2D/blend_position", jogVector)
	animation_tree.set("parameters/idleJog/transition_request", "jog")
	
func atk1():
	animation_tree.set("parameters/atkTrans/transition_request", "atk1")
	animation_tree.set("parameters/atkOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func atkAbort():
	animation_tree.set("parameters/atkOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	
func block():
	blockBlendVal = lerpf(blockBlendVal, 1, 0.2)
	animation_tree.set("parameters/blockBlend/blend_amount", blockBlendVal)
	
func blockEnd():
	blockBlendVal = lerpf(blockBlendVal, 0, 0.5)
	animation_tree.set("parameters/blockBlend/blend_amount", blockBlendVal)
	
func blockHit1():
	animation_tree.set("parameters/blockBlend/blend_amount", 1)
	animation_tree.set("parameters/blockTrans/transition_request", "blockHit1")
	animation_tree.set("parameters/blockOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	
func hit1():
	animation_tree.set("parameters/hurtTrans/transition_request", "hit1")
	animation_tree.set("parameters/hurtOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func hit2():
	animation_tree.set("parameters/hurtTrans/transition_request", "hit2")
	animation_tree.set("parameters/hurtOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func hit3():
	animation_tree.set("parameters/hurtTrans/transition_request", "hit3")
	animation_tree.set("parameters/hurtOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func hit4():
	animation_tree.set("parameters/hurtTrans/transition_request", "hit4")
	animation_tree.set("parameters/hurtOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func hit5():
	animation_tree.set("parameters/hurtTrans/transition_request", "hit5")
	animation_tree.set("parameters/hurtOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func hitDeflected1():
	animation_tree.set("parameters/hurtTrans/transition_request", "hitDeflect1")
	animation_tree.set("parameters/hurtOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func hitDeflected2():
	animation_tree.set("parameters/hurtTrans/transition_request", "hitDeflect2")
	animation_tree.set("parameters/hurtOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func stagger():
	animation_tree.set("parameters/staggerTrans/transition_request", "stagger")
	animation_tree.set("parameters/staggerBlend/blend_amount", 1)
	
func unStagger():
	animation_tree.set("parameters/staggerTrans/transition_request", "norm")
	
func setStaggerBlend(blend):
	animation_tree.set("parameters/staggerBlend/blend_amount", blend)
	
func jogScale(num):
	animation_tree.set("parameters/jogScale/scale", num)
	
func idle():
	animation_tree.set("parameters/idleJog/transition_request", "idle")
	animation_tree.set("parameters/battlePeace/transition_request", "idle")
	animation_tree.set("parameters/peaceTrans/transition_request", "idle")
	
func walk():
	animation_tree.set("parameters/idleJog/transition_request", "idle")
	animation_tree.set("parameters/battlePeace/transition_request", "idle")
	animation_tree.set("parameters/peaceTrans/transition_request", "walk")
	
func battleIdle():
	animation_tree.set("parameters/idleJog/transition_request", "idle")
	animation_tree.set("parameters/battlePeace/transition_request", "battle")
	
func feint():
	animation_tree.set("parameters/feint/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func feintAbort():
	animation_tree.set("parameters/feint/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	
func feintPunish():
	animation_tree.set("parameters/feint/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	animation_tree.set("parameters/feintPunish/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func parry():
	blockBlendVal = lerpf(blockBlendVal, 1, 0.2)
	animation_tree.set("parameters/blockBlend/blend_amount", blockBlendVal)
	parryBlendVal = lerpf(blockBlendVal, 1, 0.2)
	animation_tree.set("parameters/parryBlend/blend_amount", blockBlendVal)
	
func parryHit():
	animation_tree.set("parameters/parryOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func abortOneshots():
	animation_tree.set("parameters/parryOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	animation_tree.set("parameters/feint/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	animation_tree.set("parameters/feintPunish/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	animation_tree.set("parameters/hurtOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	animation_tree.set("parameters/atkOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	animation_tree.set("parameters/blockOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	
