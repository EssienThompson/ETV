extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 7.5
const JUMP_DURATION = 1
const DODGE_DURATION = 1.25
const SPRINT = 1.75
const SWORD_SPEED = 1.25
const DODGE_SPEED = 2.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var camera = $camRoot/twistPivot/pitchPivot/SpringArm3D/Camera3D
#@onready var camera = $camRoot/smoothCam/Camera3D
@onready var cam_root = $camRoot
@onready var area = $Area3D
@onready var man = $man
@onready var hurtB = $hurtbox
@onready var twist_pivot = $camRoot/twistPivot
@onready var pitch_pivot: Node3D = $camRoot/twistPivot/pitchPivot
#@onready var hitbo = $man/Armature/Skeleton3D/BoneAttachment3D/swordCont/sword/hitbox
@onready var hitbo: hitbox = $man/rig/Skeleton3D/BoneAttachment3D/swordCont/sword/hitbox
#@onready var manCut: MeshInstance3D = $man/Armature/Skeleton3D/man
@onready var manCut: MeshInstance3D = $man/rig/Skeleton3D/man
#@onready var sword: MeshInstance3D = $man/Armature/Skeleton3D/BoneAttachment3D/swordCont/sword/sword/Cube
#@onready var sword: MeshInstance3D = $man/rig/Skeleton3D/BoneAttachment3D/swordCont/sword/Cube
@onready var healthBar: ProgressBar = $"CanvasLayer/healthBar"
@onready var staggerBar: ProgressBar = $"CanvasLayer/staggerBar"
@onready var canvas_layer: CanvasLayer = $CanvasLayer

var isSprint := false
var isJumping := false
var jumpLand := false
var cancelSprint := false
var performDodge := false
var atkDodged := false
var bufferDodge := false
var fullscreen := false
var dodgeInterupt := false
var isAttacking := false
var isSprintAttacking := false
var isfallAttacking := false
var stopFalling := false
var isBlocking := false
var blockEndAni := false
var performParry := false
var swing1 := false # for optim put in array
var swing2 := false #
var swing3 := false #
var swing4 := false #
var velStop := false
var jumpCheck := false
var spampuni := false
var hitStunned := false
var floored := false
var floorStuck := false
var jogInterupt := false
var hitBlocked := false
var hitParried := false
var inBetweenAtk := false
var dying := false
var stagger := false
var postLower := false
var mapOpen := false
var isTalking := false
var buffer := false
var isTut := false
var timerAtkStart := false

var bufferInput := "null"
var playermode := 0 #0 = unarm, 1 = sword
var team := 0 #0 ally, 1 enemy
var damage := 0
var damageBoost := 10000 #0
var damageReduc := 0
var postureDamage := 0
var postureDmgBoost := 0
var postureReduc := 0
var hurtType := 0
var relic := []
var relicPopup := []


var jumpGrav := 10
var rollStr := 1.7
var timer := 0.0
var dodgeTimer := 0.0
var atkTimer := 0.0
var blockTimer := 0.0
var blockHitTimer := 0.0
var postureTimer := 0.0
var postLowTimer := 0.0
var parryAlt := 0
var spamTimer := 0.0
var barTimer := 0.0
var stunTimer := 0.0
var sparkTimer := 0.0
var STstart := false
var spamCount := 0
var jumpHighest := -10.0
var inBetweenThreshold := 0.0

var swing1MoveDist := 0.35
var swing2MoveDist := 0.35
var swing3MoveDist := 0.35 
var swing4MoveDist := 0.35
var swingSprtDist := 2.2
var blockMoveDist := 0.45
var swing1Move := false
var swing2Move := false
var swing3Move := false 
var swing4Move := false 
var swingSprt := false

var dodgeLerpSpd := 0.25
var atkLerpSpd := 0.1
var facing_angle : float
var timeThreshold := 0.15
var parryThreashold := 0.2
var currhp := 100.0
var maxhp := 100.0 #100
var baseMaxhp := 100.0
var maxhpBoost := 0.0
var currPosture := 0.0 
var maxPosture := 100.0 #100
var baseMaxPosture := 100.0
var maxPostureBoost:= 0.0
var dodgeStarted := false
var lockOnTargets := []
var lockOnChoice := []
var los := false

var direction := Vector3.ZERO
var dodgeVec := Vector3.ZERO
var attackVec := Vector3.ZERO
var target_direction: = Vector3.ZERO
var non0Dir := Vector3.ZERO
var input_dir := Vector2.ZERO
var atkDir := Vector3.ZERO
var attackerDir := Vector3.ZERO

func _physics_process(delta):
	playermode = 1
	if playermode == 0:
		man.unarm()
	elif playermode == 1:
		man.sword() 
	man.sword() 
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= 1.5 * jumpGrav * delta
	else:
		velocity.y -= gravity * delta
		isJumping = false
		
	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor() and !performDodge and !isAttacking and !isTalking and !mapOpen: 
		doJump()
		
	if isJumping && jumpCheck:
			man.jumpSword()
			jumpCheck = false
	if jumpHighest <= global_transform.origin.y && isJumping:
		jumpHighest = global_transform.origin.y
	if jumpHighest > global_transform.origin.y:
		isJumping = false
		jumpLand = true
		jumpHighest = -10
		
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var cam_rotate = twist_pivot.rotation.y
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	direction = (Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, cam_rotate)
	direction = -direction.normalized()
	
	if direction != Vector3.ZERO:
		if performDodge:
			non0Dir = non0Dir
		else:
			non0Dir = direction
		
	if !isAttacking or inBetweenAtk or direction != Vector3.ZERO:
		atkDir = non0Dir
		
	
	if dying: 
		stunTimer += delta
		velocity = Vector3.ZERO
		if stunTimer <= 4:
			interrupt()
		else:
			game_over()
		
	if stagger:
		man.stagger() 
		stunTimer += delta
		velocity = Vector3.ZERO
		if stunTimer <= 1.5:
			interrupt()
			man.abortOneShot()
		else:
			man.unStagger()
			jogInterupt = false
			dodgeInterupt = false
			stagger = false
			stunTimer = 0
			currPosture = 0
		
	
	if floorStuck:
		velocity = Vector3.ZERO
		interrupt()
		dodgeInterupt = false
		man.floorStuck()
		if performDodge:
			floorStuck = false
			jogInterupt = false
			man.floorUnstuck()
			
	if isTalking:
		velocity = Vector3.ZERO
	
	if hitStunned:
		stunTimer += delta
		if floored:
			if stunTimer <= 0.3:
				velocity.x = (-attackerDir.x * SPEED)*10
				velocity.z = (-attackerDir.z * SPEED)*10
			if stunTimer <= 0.5:
				interrupt()
			else:
				dodgeInterupt = false
				jogInterupt = false
				floored = false
				floorStuck = true
				stunTimer = 0
				hitStunned = false
		else:
			if stunTimer <= 0.15:
				interrupt()
				velocity.x = (-attackerDir.x * SPEED)/2
				velocity.z = (-attackerDir.z * SPEED)/2
			else:
				dodgeInterupt = false
				jogInterupt = false
				stunTimer = 0
				hitStunned = false
		
	elif isAttacking:
		#currhp -= currhp #test death
		#currPosture = maxPosture #test stagger
		if velStop:
			if isSprint:
				velocity = velocity/1.5
			else:
				velocity = Vector3.ZERO
			velStop = false
			isSprint = false
			timerAtkStart = true
		if isfallAttacking:
			
			if atkTimer >= 0.5:
				stopFalling = false
			else:
				stopFalling = true
				
			if is_on_floor():
				isAttacking = false
				isfallAttacking = false
				hitbo.activeOff()
				
		elif isSprintAttacking:
			if swingSprt:
				velocity.x = attackVec.x/1.5
				velocity.z = attackVec.z/1.5
				
			elif (atkTimer >= 0.8/SWORD_SPEED &&  atkTimer <= 1/SWORD_SPEED) or isBlocking:
				inBetweenAtk = true
				inBetweenThreshold = 1/SWORD_SPEED
				isAttacking = false
			
		elif swing4:
			if swing4Move:
				velocity.x = attackVec.x
				velocity.z = attackVec.z
				
			elif (atkTimer >= 0.75/SWORD_SPEED && atkTimer <= 0.95/SWORD_SPEED) or isBlocking:
				inBetweenAtk = true
				inBetweenThreshold = 0.95/SWORD_SPEED
				isAttacking = false
				
		elif swing3:
			if swing3Move:
				velocity.x = attackVec.x
				velocity.z = attackVec.z
				
			elif (atkTimer >= 0.75/SWORD_SPEED && atkTimer <= 0.95/SWORD_SPEED) or isBlocking:
				inBetweenAtk = true
				inBetweenThreshold = 0.95/SWORD_SPEED
				isAttacking = false
				
		elif swing2:
			if swing2Move:
				velocity.x = attackVec.x
				velocity.z = attackVec.z
				
			elif (atkTimer >= 0.75/SWORD_SPEED && atkTimer <= 0.95/SWORD_SPEED) or isBlocking:
				inBetweenAtk = true
				inBetweenThreshold = 0.95/SWORD_SPEED
				isAttacking = false
				
		elif swing1:
			if swing1Move:
				velocity.x = attackVec.x
				velocity.z = attackVec.z
				
			elif (atkTimer >= 0.75/SWORD_SPEED && atkTimer <= 0.95/SWORD_SPEED) or isBlocking:
				inBetweenAtk = true
				inBetweenThreshold = 0.95/SWORD_SPEED
				isAttacking = false
				
		######################################################################################
	elif performDodge and !isAttacking:
		dodgeTimer += delta
		dodgeInterupt = true
		if dodgeTimer <= 0.35:
			atkDodged = true
		else:
			atkDodged = false
		if dodgeTimer >= DODGE_DURATION/DODGE_SPEED:
			performDodge = false
			dodgeInterupt = false 
			dodgeTimer = 0 
		
			if bufferInput == "ATK":
				swing1 = true
				attackSetup()
				bufferInput = "null"
			elif bufferInput == "DOD":
				dodgeSetup()
				bufferDodge = false
				bufferInput = "null"
		if atkDodged:
			velocity.x = lerp(velocity.x, dodgeVec.x, dodgeLerpSpd)
			velocity.z = lerp(velocity.z, dodgeVec.z, dodgeLerpSpd)
			#velocity.x = dodgeVec.x
			#velocity.z = dodgeVec.z
		else:
			velocity = Vector3.ZERO
		######################################################################################
	elif hitBlocked:
		blockHitTimer += delta
		if blockHitTimer >= 0.0 && blockHitTimer <= 0.35:
			velocity.x = -attackerDir.x * SPEED * blockMoveDist
			velocity.z = -attackerDir.z * SPEED * blockMoveDist
		elif blockHitTimer >= 0.5:
			blockHitTimer = 0.0
			hitBlocked = false
	elif isSprint and is_on_floor() and !isAttacking && !performDodge && !mapOpen:
		velocity.x = direction.x * SPEED * SPRINT
		velocity.z = direction.z * SPEED * SPRINT
	elif isJumping and isSprint and !isAttacking && !performDodge && !mapOpen:
		velocity.x = (direction.x * SPEED * SPRINT)
		velocity.z = (direction.z * SPEED * SPRINT)
	elif isJumping and !isAttacking && !performDodge && !mapOpen:
		velocity.x = ((direction.x/2) * SPEED * SPRINT) 
		velocity.z = ((direction.z/2) * SPEED * SPRINT) 
	elif !isAttacking && !jogInterupt && !performDodge && !mapOpen:
		velocity.x = direction.x * SPEED 
		velocity.z = direction.z * SPEED

	move_and_slide()
	
	man.rotation.y = lerp_angle(man.rotation.y, facing_angle, 0.25)
	
	
	
func _process(delta: float) -> void:
	if currPosture >= maxPosture:
		stagger = true
	if currhp <= 0: #TO#DO change to 0
		if !isTut:
			dying = true
			manCut.death = true
	elif currhp > maxhp:
		currhp = maxhp
		
	if currPosture <= 0:
		currPosture = 0
		
	if currPosture <= 0:
		staggerBar.visible = false
	else: 
		staggerBar.visible = true
	
	healthBar.value = currhp
	staggerBar.value = currPosture
		
	if (postureTimer <= 3 && postLower == false && !isBlocking) or (postureTimer <= 1.5 && postLower == false && isBlocking):
		postureTimer += delta
	else:
		if currPosture > 0:
			postLower = true
		else:
			postLower = false
		
		
	if postLower:
		#var newPosture : float
		postLowTimer += delta
		if postLowTimer >= 0.1:
			if isBlocking:
				currPosture = currPosture - (maxPosture*0.015)
			else:
				currPosture = currPosture - (maxPosture*0.01)
			postLowTimer = 0.0
			
		#currPosture = lerpf(currPosture, newPosture, 0.01)
		
		
	if mapOpen:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if lockOnTargets.is_empty():
		los = false
		#return ,TO#DO dunno if it affect lockOn logic but turn off. if needed move to end of process
	for enemy in lockOnTargets:
		var space_state = get_world_3d().direct_space_state
		var mousepos = get_viewport().get_mouse_position()
		var origin = camera.project_ray_origin(mousepos)
		var enemyPos = enemy.global_transform.origin
		var enemyDir = (enemyPos - origin).normalized()
		var distToEnemy = origin.distance_to(enemyPos)
		var end = origin + enemyDir * distToEnemy
		var colliMask: int =  (1 << 0) | (1 << 6)
		var query = PhysicsRayQueryParameters3D.create(origin, end, colliMask)
		#DrawLine3d.DrawLine(origin, end, Color(0, 1, 0), 2)
		query.exclude = [self]
		query.collide_with_areas = true
		var result = space_state.intersect_ray(query)
		if result and result.get("collider") == enemy: 
			los = true
			if (enemy.dying == true or enemy == null) and enemy in lockOnChoice:
				lockOnChoice.erase(enemy)
			elif enemy not in lockOnChoice && enemy != null && enemy.dying != true:
				lockOnChoice.append(enemy)
		else:
			if lockOnChoice != null && result.get("collider") != null:
				if enemy in lockOnChoice:
					if result.get("collider").is_in_group("lockOn"):
						cam_root.keepLock = true
					else:
						lockOnChoice.erase(enemy)
						
		
						
	if lockOnChoice != null:
		for enemy in lockOnChoice:
			if enemy == null:
				lockOnChoice.erase(enemy)
			elif enemy == cam_root.target && cam_root.lockOn && enemy.dying == false:
				enemy.barVisible = true
			else:
				barTimer += delta
				if barTimer >= 0.2:
					if enemy != null:
						enemy.barVisible = false
					barTimer = 0
	
	if input_dir.length() > 0 and (!cam_root.lockOn && !isAttacking && !floorStuck && !hitStunned && !hitBlocked && !performDodge && !dying && !stagger && !isTalking && !inBetweenAtk && !isSprintAttacking):
		facing_angle = Vector2(direction.z, direction.x).angle()
	elif (inBetweenAtk or performDodge && !floorStuck && !dying && !stagger) && !cam_root.lockOn: #inbetweenAtk or at start comma(removed)
		facing_angle = Vector2(non0Dir.z, non0Dir.x).angle()
	#elif isSprintAttacking:
		#facing_angle = Vector2(atkDir.z, atkDir.x).angle()
	elif hitStunned or hitBlocked:
		facing_angle = Vector2(attackerDir.z, attackerDir.x).angle()
	elif cam_root.lockOn && (isSprint && !performDodge && !isAttacking):
		facing_angle = Vector2(direction.z, direction.x).angle()
	elif cam_root.lockOn && !floorStuck:
		var lock_on_target = cam_root.target
		if lock_on_target and lock_on_target != null:
			target_direction = (lock_on_target.global_transform.origin - global_transform.origin).normalized()
			if !dying && !stagger:
				facing_angle = Vector2(target_direction.z, target_direction.x).angle()
			
	if playermode == 0:
		if input_dir.length() == 0 and !performDodge:
			man.idle()
		elif isSprint:
			man.run()
		elif input_dir.length() < 0.5:
			man.walk()
		elif input_dir.length() > 0.5:
			man.jogstr()
	elif playermode == 1:
		if is_on_floor() && jumpLand && !isJumping && !isAttacking:
			man.fallSwordLand()
			jumpLand = false
		if not is_on_floor() && !isJumping && !isAttacking && !floorStuck && !stopFalling:
			#print("fal")
			man.fallSword()
		elif input_dir.length() == 0 and !performDodge and !isJumping and is_on_floor() && !floorStuck && !jumpLand or hitBlocked:
			man.idleSword()
			#print("idle")
		elif isSprint && is_on_floor() and !performDodge and !isJumping && !floorStuck or hitBlocked:
			man.runSword()
			#print("run")
		elif input_dir.length() < 0.5 && is_on_floor() && !jogInterupt and !performDodge and !isJumping && !floorStuck or hitBlocked:
			man.walkSword()
			#print("walk")
		elif input_dir.length() > 0.5 && is_on_floor() && !jogInterupt and !performDodge and !isJumping && !floorStuck or hitBlocked:
			man.jogSword()
			#print("jog")
	
	if Input.is_action_just_pressed("sprint") and !mapOpen and !isTalking:
		dodgeStarted = true
		
	if Input.is_action_pressed("sprint") && dodgeStarted:
		timer += delta
		
	if timer >= timeThreshold && dodgeStarted:
		dodgeStarted = false
		timer = 0
		if !isJumping:
			isSprint = true
		
	if Input.is_action_just_released("sprint") and !mapOpen and !isTalking:
		if timer <= timeThreshold && dodgeStarted && !dodgeInterupt && !isBlocking:
			dodgeSetup()
		dodgeStarted = false
		timer = 0
		if is_on_floor():
			isSprint = false
		else:
			cancelSprint = true
	
	if cancelSprint and is_on_floor():
		isSprint = false
		cancelSprint = false
		
	if Input.is_action_pressed("block") and (!isAttacking or !performDodge) and !mapOpen and !isTalking and !hitStunned:
		cancelSprint = true
		blockEndAni = false
		man.swordBlockStart()
		blockTimer += delta
		isBlocking = true
		performParry = true
		STstart = true
		if blockTimer >= parryThreashold:
			performParry = false

	if STstart:
		spamTimer += delta 

	if Input.is_action_just_released("block") and (!isAttacking or !performDodge):
		blockEndAni = true
		isBlocking = false
		blockTimer = 0
		spamCount += 1
		
		if spamCount >= 5 and spamTimer <= 0.75:
			parryThreashold = 0.05
			spamTimer = 0
			
	if spamTimer > 0.75:
		spamTimer = 0
		spamCount = 0
		parryThreashold = 0.2
		STstart = false
	
	if blockEndAni:
		if man.blendVal <= 0.001: 
			blockEndAni = false
		man.swordBlockEnd()
		
	#if hitParried:
		#if parryAlt == 1:  #reversed cause code ordering
			#man.sparksActi()
		#elif parryAlt == 0:
			#man.sparksActi2()
			#
	#elif hitBlocked:
		#if parryAlt == 1:  #reversed cause code ordering
			#man.sparksActi()
		#elif parryAlt == 0:
			#man.sparksActi2()
			
	if hitBlocked == false:
		sparkTimer = 0
	
	if Input.is_action_just_pressed("attack") and (isAttacking or performDodge or inBetweenAtk) and is_on_floor() and !floorStuck:
		bufferInput = "ATK"
		bufferDodge = false
		
	if bufferInput == "ATK" && floorStuck:
		bufferInput = "null"
		
	if Input.is_action_just_pressed("attack") and !isAttacking and !performDodge and !isSprint and !hitStunned and is_on_floor() and !floorStuck and !inBetweenAtk and !mapOpen and !isBlocking and !isTalking:
		swing1 = true
		attackSetup()
		
	if Input.is_action_just_pressed("sprint") and bufferDodge and (isAttacking or performDodge or inBetweenAtk):
		bufferInput = "DOD"
		bufferDodge = false
	
	if Input.is_action_just_pressed("attack") and isSprint and !hitStunned and is_on_floor() and !floorStuck and !mapOpen:
		isSprintAttacking = true
		attackSetup()
		
	if Input.is_action_just_pressed("attack") and !hitStunned and !is_on_floor() and !mapOpen and !isfallAttacking:
		isfallAttacking = true
		attackSetup()
		
		
	if Input.is_action_just_pressed("fullscreen"):
		fullscreen = !fullscreen
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	if timerAtkStart:
		atkTimer += delta
		
	if inBetweenAtk:
		if isBlocking:
			atkTimer = 0
			inBetweenAtk = false
			isAttacking = false
			swingFalse()
			bufferInput = "null"
			hitbo.activeOff()
					
		if bufferInput == "ATK":
			atkTimer = 0
			inBetweenAtk = false
			nextSwing()
			attackSetup()
			bufferInput = "null"
			hitbo.activeOff()
						
		elif bufferInput == "DOD":
			atkTimer = 0
			inBetweenAtk = false
			swingFalse()
			isAttacking = false
			bufferInput = "null"
			dodgeSetup()
			hitbo.activeOff()
						
		if atkTimer >= inBetweenThreshold:#TODO find way to turn off inbet after time
			atkTimer = 0
			timerAtkStart = false
			inBetweenAtk = false
			isAttacking = false
			swingFalse()
			hitbo.activeOff()
			#velocity = Vector3.ZERO
	
	if isSprintAttacking:
		if atkTimer <= 0.25/SWORD_SPEED:
			swingSprt = true
		else:
			swingSprt = false
	elif swing4:
			if atkTimer >= 0.4/SWORD_SPEED && atkTimer < 0.5/SWORD_SPEED:
				swing4Move = true
			else:
				swing4Move = false
	elif swing3:
			if atkTimer >= 0.4/SWORD_SPEED && atkTimer < 0.5/SWORD_SPEED:
				swing3Move = true
			else:
				swing3Move = false
	elif swing2:
			if atkTimer >= 0.4/SWORD_SPEED && atkTimer < 0.5/SWORD_SPEED:
				swing2Move = true
			else:
				swing2Move = false
	elif swing1:
			if atkTimer >= 0.4/SWORD_SPEED && atkTimer < 0.5/SWORD_SPEED:
				swing1Move = true
			else:
				swing1Move = false
				
	
	if isTalking:
		interrupt()
		hideUi()
		
	if buffer:
		timer += delta
		if timer >= 0.15:
			isTalking = false
			buffer = false
			jogInterupt = false
			dodgeInterupt = false
			showUi()
			timer = 0
		

func game_over():
	get_tree().reload_current_scene()
	
func _ready():
	area.connect("body_entered", Callable(self, "_on_Body_Entered"))
	area.connect("body_exited", Callable(self, "_on_Body_Exited"))
	man.floorUnstuck()
	man.swordSwingSpd(SWORD_SPEED)
	man.swordDodgeSpd(DODGE_SPEED)
	healthBar.max_value = maxhp
	staggerBar.max_value = maxPosture
	healthBar.value = maxhp
	Events.showMap.connect(mapIsOn)
	Events.hideMap.connect(mapIsOff)
	Events.relicAdded.connect(relicAdded)
	Dialogic.signal_event.connect(dialogicSignals)
	
	
func _on_Body_Entered(body):
	#print("body entered")
	if body.is_in_group("lockOn"):
		lockOnTargets.append(body)
		#print(lockOnTargets)
		
func _on_Body_Exited(body):
	#print("body exit")
	if body in lockOnTargets:
		lockOnTargets.erase(body)
		#print(lockOnTargets)
		
func attackSetup():
	velStop = true
	if swing4: 
		damage = 75
		postureDamage = 20
		isAttacking = true
		hurtType = 2
		man.swordSwing4()
		if cam_root.lockOn and !isSprint:
			attackVec.x = target_direction.x * SPEED * swing4MoveDist
			attackVec.z = target_direction.z * SPEED * swing4MoveDist
		else:
			attackVec.x = atkDir.x * SPEED * swing4MoveDist 
			attackVec.z = atkDir.z * SPEED * swing4MoveDist
	elif swing3:
		damage = 50
		postureDamage = 10
		hurtType = 1
		isAttacking = true
		man.swordSwing3()
		if cam_root.lockOn and !isSprint:
				attackVec.x = target_direction.x * SPEED * swing3MoveDist
				attackVec.z = target_direction.z * SPEED * swing3MoveDist
		else:
			attackVec.x = atkDir.x * SPEED * swing3MoveDist 
			attackVec.z = atkDir.z * SPEED * swing3MoveDist
	elif swing2:
		damage = 50
		postureDamage = 10
		hurtType = 2
		isAttacking = true
		man.swordSwing2()
		if cam_root.lockOn and !isSprint:
			attackVec.x = target_direction.x * SPEED * swing2MoveDist
			attackVec.z = target_direction.z * SPEED * swing2MoveDist
		else:
			attackVec.x = atkDir.x * SPEED * swing2MoveDist 
			attackVec.z = atkDir.z * SPEED * swing2MoveDist
	elif swing1:
		damage = 50
		postureDamage = 10
		hurtType = 1
		isAttacking = true
		man.swordSwing1()
		if cam_root.lockOn and !isSprint:
			attackVec.x = target_direction.x * SPEED * swing1MoveDist
			attackVec.z = target_direction.z * SPEED * swing1MoveDist
		else:
			attackVec.x = atkDir.x * SPEED * swing1MoveDist 
			attackVec.z = atkDir.z * SPEED * swing1MoveDist
	elif isSprintAttacking:
		damage = 50
		postureDamage = 10
		hurtType = 3
		isAttacking = true
		man.SwordSprintSwing()
		if cam_root.lockOn and !isSprint:
			attackVec.x = target_direction.x * SPEED * swingSprtDist
			attackVec.z = target_direction.z * SPEED * swingSprtDist
		else:
			attackVec.x = atkDir.x * SPEED * swingSprtDist 
			attackVec.z = atkDir.z * SPEED * swingSprtDist
	elif isfallAttacking:
		damage = 50
		postureDamage = 10
		hurtType = 3
		isAttacking = true
		velStop = false
		man.fallSwordSwing()
		
		
	damage = damage + ((damageBoost/100)*damage)
	postureDamage = postureDamage + ((postureDmgBoost/100)*postureDamage)

				
func dodgeSetup():
	if isAttacking == true: #add for blocking too
		bufferDodge = true
	else:
		performDodge = true # need to set false somewhere
	if playermode == 0:
		man.dodge()
	elif playermode == 1:
		man.dodgeSword()
	if direction == Vector3.ZERO and cam_root.lockOn:
		dodgeVec.x = -target_direction.x * SPEED * rollStr
		dodgeVec.z = -target_direction.z * SPEED * rollStr
	elif direction == Vector3.ZERO:
		dodgeVec.x = -non0Dir.x * SPEED * rollStr
		dodgeVec.z = -non0Dir.z * SPEED * rollStr
	else:
		dodgeVec.x = direction.x * SPEED * rollStr
		dodgeVec.z = direction.z * SPEED * rollStr

func isHit(hitInfo):
	var Entityteam = hitInfo[0]
	var damageDealt = hitInfo[1]
	var postureRecieved = hitInfo[2]
	var entityHurtType = hitInfo[3]
	var entityOrigin = hitInfo[4]
	isAttacking = false
	
	postureRecieved = calcPostureReduc(postureRecieved)
	damageDealt = calcDamageReduc(damageDealt)
		
	if Entityteam != team:
		if performParry:
			hitBlocked = true
			parryThreashold = 0.2
			if parryAlt == 0:
				man.parry1()
				parryAlt += 1
			else:
				man.parry2()
				parryAlt = 0
				
			match entityHurtType:
				1:
					man.sparksActi(2)
					man.lineActi(2)
					currPosture = currPosture - 10 
					hitParried = true
					cam_root.startShake(0.1, 0.25)
				2:
					man.sparksActi(3)
					man.lineActi(3)
					currPosture = currPosture - 10 
					hitParried = true
					cam_root.startShake(0.1, 0.25)
				3:
					man.sparksActi(4)
					man.lineActi(4)
					currPosture = currPosture - 10 
					hitParried = true
					cam_root.startShake(0.1, 0.25)
				4:
					man.sparksActi(1)
					man.lineActi(1)
					currPosture = currPosture - 10 
					hitParried = true
					cam_root.startShake(0.1, 0.25)
				5:
					man.abortOneShot()
					isBlocking = false
					hitStunned = true
					floored = true
					cam_root.startShake(0.5, 0.25)
					blockEndAni = true
					man.hit5Sword()
					interrupt()
					currhp = currhp - damageDealt
					attackerDir = (entityOrigin - global_transform.origin).normalized()
					postureTimer = 0.0
					postLower = false
					
				
		elif isBlocking:
			man.swordBlockHit()
			match entityHurtType:
				1:
					man.sparksActi(2)
					currPosture = currPosture + postureRecieved 
					cam_root.startShake(0.1, 0.25)
					hitBlocked = true
				2:
					man.sparksActi(3)
					currPosture = currPosture + postureRecieved 
					cam_root.startShake(0.1, 0.25)
					hitBlocked = true
				3:
					man.sparksActi(4)
					currPosture = currPosture + postureRecieved 
					cam_root.startShake(0.1, 0.25)
					hitBlocked = true
				4:
					man.sparksActi(1)
					currPosture = currPosture + postureRecieved 
					cam_root.startShake(0.1, 0.25)
					hitBlocked = true
				5:
					man.abortOneShot()
					isBlocking = false
					hitStunned = true
					floored = true
					cam_root.startShake(0.5, 0.25)
					blockEndAni = true
					man.hit5Sword()
					interrupt()
					currhp = currhp - damageDealt
					attackerDir = (entityOrigin - global_transform.origin).normalized()
					postureTimer = 0.0
					postLower = false
					
				

		elif atkDodged:
			pass # no dmg maybe + resource
		else:
			interrupt()
			man.abortOneShot()
			if stagger:
				stagger = false
				stunTimer = 0
				currPosture = 0
				man.unStagger()
				currhp = currhp - damageDealt*2
				#dodgeInterupt = false
				#jogInterupt = false
			else:
				currhp = currhp - damageDealt
			match entityHurtType:
				1:
					man.hit1Sword()
				2:
					man.hit2Sword()
				3:
					man.hit3Sword()
				4:
					man.hit4Sword()
				5:
					man.hit5Sword()
					floored = true
			hitStunned = true
			if entityHurtType == 5:
				cam_root.startShake(0.5, 0.25)
			else:
				cam_root.startShake(0.25, 0.25)
			
		attackerDir = (entityOrigin - global_transform.origin).normalized()
		postureTimer = 0.0
		postLower = false
		if isTalking:
			buffer = true
	
func doJump():
	velocity.y = 2*JUMP_VELOCITY/JUMP_DURATION
	jumpGrav = velocity.y / JUMP_DURATION
	isJumping = true
	jumpCheck = true

func interrupt():
	dodgeInterupt = true #turn back flase somewhere
	hitbo.active = false
	isAttacking = false
	inBetweenAtk = false
	isJumping = false
	cancelSprint = true
	isBlocking = false
	jogInterupt = true
	swing1 = false
	swing2 = false
	swing3 = false
	swing4 = false
	isfallAttacking = false
	isSprintAttacking = false
	
	
func hideUi() -> void:
	canvas_layer.visible = false
	
func showUi() -> void:
	canvas_layer.visible = true
	
func mapIsOn() -> void:
	hideUi()
	mapOpen = true
	
func mapIsOff() -> void:
	showUi()
	mapOpen = false
	
func calcPostureReduc(postureRecieved:float) -> float:
	var reduc = (postureReduc/100) 
	reduc = minf(reduc, 0.4) #cant go over 40%
	postureRecieved = postureRecieved - (reduc * postureRecieved)
	return postureRecieved
	
func calcDamageReduc(damageRecieved:float) -> float:
	var reduc = (damageReduc/100) 
	reduc = minf(reduc, 0.4) #cant go over 40%
	damageRecieved = damageRecieved - (reduc * damageRecieved)
	return damageRecieved
	
	
func updMaxHp():
	maxhp = baseMaxhp + (baseMaxhp*(maxhpBoost/100))
	
func updMaxPosture():
	maxPosture = baseMaxPosture + (baseMaxPosture*(maxPostureBoost/100))
	
func updBarMaxVal():
	healthBar.max_value = maxhp
	staggerBar.max_value = maxPosture
	
func relicAdded():
	var temphpBoost = 0
	var tempPosBoost = 0
	var tempDmgBoost = 0
	var tempPosDmgBoost = 0
	var tempDmgRedu = 0
	var tempPosRedu = 0
	
	for rel in relic:
		match rel:
			100:
				temphpBoost += 50
				
	
	maxhpBoost = temphpBoost 
	maxPostureBoost = tempPosBoost
	damageBoost = tempDmgBoost
	postureDmgBoost = tempPosDmgBoost
	damageReduc = tempDmgRedu
	postureReduc = tempPosRedu
	updMaxPosture()
	updMaxHp()
	updBarMaxVal()
	
	
func dialogicSignals(sig):
	if sig == "stopTalk":
		buffer = true
		
func nextSwing():
	isAttacking = true
	if swing1 == true:
		swing1 = false
		swing2 = true
	elif swing2 == true:
		swing2 = false
		swing3 = true
	elif swing3 == true:
		swing3 = false
		swing4 = true
	elif swing4 == true:
		swing4 = false
		swing1 = true
	elif isSprintAttacking == true:
		isSprintAttacking = false
		swing1 = true
		
func swingFalse():
	swing1 = false 
	swing2 = false 
	swing3 = false 
	swing4 = false 
	isSprintAttacking = false
	isfallAttacking = false
	
