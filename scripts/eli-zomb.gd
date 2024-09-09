extends CharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var animation_tree = $Armature/Skeleton3D/AnimationPlayer/AnimationTree
@onready var detectArea = $detectArea
@onready var armature = $Armature
@onready var nav = $NavigationAgent3D
@onready var hitB = $Armature/Skeleton3D/BoneAttachment3D/hitbox
@onready var shield_hitbox = $Armature/Skeleton3D/shield/shieldHitbox
@onready var eli_zomb_mesh: MeshInstance3D = $"Armature/Skeleton3D/eli-zombMesh"
@onready var health_bar_3d: Node3D = $CollisionShape3D/HealthBar3D

const ENEMY_TYPE = "elite"
const SPEED = 9 #9
enum {
	IDLE,
	CHASE,
	ATTACK,
	STAGGERED,
	BLOCK,
	HOVER,
	DEATH,
}
var trans = false
var clockwise = false
var state = IDLE
var team := 1
var damage := 0
var postureDamage := 0 
var hurtType := 0
var hp = 400
var maxHp = 800 # 800
var posture = 0 # crip will have no stagger (maybe not)
var maxPosture = 150 #150 might go higher
var blendVal := 0.0

var direction := Vector3.ZERO
var targetPos := Vector3.ZERO
var atkDir:= Vector3.ZERO
var player
var facing_angle : float
var angle : float
var hoverRadius := 7.5
var timer := 0.0
var staggerTimer := 0.0
var deathTimer := 0.0
var timerThresh := 0.0
var barTimer := 0.0
var postureTimer := 0.0
var postLowTimer := 0.0
var facingThresh := 0.0
var rando := 0.0
var stringCount := 1
var hoverMissCount := 0
var blockHitCount := 0
var oldVal := 0

var once := false
var randOnce := false
var hoverOver := false
var veloZero := false
var atkMove := false
var C1S3Spec := false
var midRange := false
var shieldBash := false
var hitBlocked := false
var retalRand := false
var blockEndAni := false
var afterSB : bool
var blockChance := false
var rotati := false
var dying := false
var barVisible := false
var postLower := false

# Called when the node enters the scene tree for the first time.
func _ready():
	detectArea.connect("body_entered", Callable(self, "_on_Body_Entered"))
	detectArea.connect("body_exited", Callable(self, "_on_Body_Exited"))
	shield_hitbox.user = self
	hitB.user = self
	hp = maxHp
	health_bar_3d.setStaggerMax(maxPosture)
	health_bar_3d.setHealthMax(maxHp)
	health_bar_3d.fullBar()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	match state:
		IDLE:
			velocity.x = 0
			velocity.z = 0
		CHASE:
			velocity.x = direction.x * SPEED 
			velocity.z = direction.z * SPEED
			
		HOVER:
			velocity.x = direction.x * SPEED/1.75
			velocity.z = direction.z * SPEED/1.75
		
		ATTACK:
			if veloZero:
				velocity.x = 0
				velocity.z = 0
			elif atkMove:
				velocity.x = atkDir.x * SPEED 
				velocity.z = atkDir.z * SPEED
				
		STAGGERED:
			velocity.x = 0
			velocity.z = 0
			
		DEATH:
			velocity.x = 0
			velocity.z = 0
				
			
	move_and_slide()
	var rot
	if rotati == true:
		rot = facing_angle - global_rotation.y
		if hitBlocked:
			armature.rotation.y = lerp_angle(armature.rotation.y, rot, 0.25)
		else:
			armature.rotation.y = lerp_angle(armature.rotation.y, rot, 0.08)
	else:
		if hitBlocked:
			armature.rotation.y = lerp_angle(armature.rotation.y, facing_angle, 0.25)
		else:
			armature.rotation.y = lerp_angle(armature.rotation.y, facing_angle, 0.08)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	health_bar_3d.healthCurr(hp)
	health_bar_3d.staggerCurr(posture)
	
	if barVisible == true:
		health_bar_3d.visible = true
	else:
		barTimer += delta
		if barTimer >= 2:
			health_bar_3d.visible = false
			barTimer = 0
		
	if postureTimer <= 5 && postLower == false:
		postureTimer += delta
	else:
		if posture > 0:
			postLower = true
		
	if postLower:
		postLowTimer += delta
		if postLowTimer >= 0.1:
			posture = posture - (maxPosture*0.01)
			postLowTimer = 0.0
			if posture <= 0:
				posture = 0
			
	if posture >= maxPosture:
		state = STAGGERED
		#health_bar_3d.staggerColorRed()
	#elif posture >= maxPosture/2:
		#health_bar_3d.staggerColorOrange()
	#else:
		#health_bar_3d.staggerColorYellow()
	health_bar_3d.staggerColor()
	if hp <= 0:
		state = DEATH #add death
		eli_zomb_mesh.death = true
		dying = true
		
	match state: 
		IDLE:
			if trans:
				cripIdle()
			else:
				idle()
		CHASE:
			jog()
			if player == null:
				return
			else:
				targetPos = player.global_transform.origin
				nav.target_position = targetPos
				direction = (nav.get_next_path_position() - global_transform.origin).normalized()
				var distToPlayer = global_transform.origin.distance_to(targetPos)
				if once: # set once in body entered
					rando = randi_range(1, 4)
					if rando >= 2:
						hoverOver = true
					once = false
					hoverMissCount += 1
					
				if hoverMissCount == 4:
					hoverOver = false
					hoverMissCount = 0
				
				if hoverOver:
					if distToPlayer <= 4:
						state = ATTACK
						hoverOver = false
				elif distToPlayer <= hoverRadius:
					state = HOVER
					hoverMissCount = 0
					hoverOver = false
					once = true
					randOnce = true
			facing_angle = Vector2(direction.z, direction.x).angle()
			
		HOVER:
			targetPos = player.global_transform.origin
			#var distToPlayer = global_transform.origin.distance_to(targetPos) 
			timer += delta
			if randOnce:
				rando = randf_range(2, 4) # make rand numb from 2 - 5 sec
				randOnce = false
			if timer >= rando:
				#state = CHASE 
				hoverOver = true
				timer = 0
			if is_on_wall() && timer <= rando && once:
				clockwise = !clockwise
				once = false
			elif is_on_wall() && once == false:
				#state = CHASE
				hoverOver = true
				timer = 0
			
			if clockwise:
				angle -= SPEED/1.5 * delta/hoverRadius  # CounterClockwise movement
			else:
				angle += SPEED/1.5 * delta/hoverRadius  # clockwise movement
				
			angle = wrapf(angle, 0, PI * 2)  # Keep the angle within the range [0, 2π]
			var x = hoverRadius * cos(angle)
			var z = hoverRadius * sin(angle)
			var new_position = player.global_position + Vector3(x, 0, z)
			direction = (new_position - global_transform.origin).normalized()
			jog()
			var circleDir = (targetPos - global_transform.origin).normalized()
			facing_angle = Vector2(circleDir.z, circleDir.x).angle()
			
		ATTACK:
			var blockChance : bool
			targetPos = player.global_transform.origin
			var distToPlayer = global_transform.origin.distance_to(targetPos)
			direction = (targetPos - global_transform.origin).normalized()
			timer += delta
			#print(distToPlayer) # <4 == no move <9 move atk 9+ cancel
			if distToPlayer <= 3.8:
				if stringCount == 5:
					blockChance = true
				veloZero = true
				midRange = false
			elif distToPlayer <= 7.5:
				veloZero = false
				midRange = true
			elif timer >= timerThresh:
				stringCount = 5
				midRange = false
				atkAbort()
			if stringCount != 5 && timer >= timerThresh:
				performC1()
			elif stringCount == 5 && timer >= timerThresh:
				if blockChance == true:
					rando = randi_range(1, 2)
				if rando == 1 && blockChance == true:
					timer = 0
					timerThresh = 0
					facingThresh = 0
					stringCount = 1
					state = BLOCK
					blockChance = false
				else:
					timer = 0
					timerThresh = 0
					facingThresh = 0
					stringCount = 1
					once = true
					state = CHASE
					blockChance = false
				
			if timer <= facingThresh:
				facing_angle = Vector2(direction.z, direction.x).angle()
				atkDir = direction
				
			if C1S3Spec:
				if timer >= 0.8 && timer <= 1:
					hurtType = 3
				elif timer >= 1.15 && timer <= 1.35:
					hurtType = 2
				elif timer >= 1.5 && timer <= 1.7:
					hurtType = 3
				else: 
					hurtType = 1
				
			if timer >= facingThresh:
				if C1S3Spec == false:
					atkMove = true
				if midRange:
					veloZero = false
			else: 
				atkMove = false
				if midRange:
					veloZero = true
			#print(facingThresh)
			
		BLOCK:
			block()
			timer += delta
			targetPos = player.global_transform.origin
			var distToPlayer = global_transform.origin.distance_to(targetPos)
			direction = (targetPos - global_transform.origin).normalized()
			if blockHitCount == 5:
				shieldBash = true
				blockHitCount = 0
				oldVal = 0
				timer = 0
				retalRand = true
			if afterSB && timer >= 1:
				afterSB = false
				timer = 0
			if shieldBash:
				afterSB = true
				blockBash()
				damage = 40
				postureDamage = 30
				hurtType = 5 # 1
				shieldBash = false
			if hitBlocked && !afterSB:
				timer = 0
				hitBlocked = false
			if distToPlayer >= 4.5 && timer >= 1.4:#i chose 1.4 just casue
				state = CHASE 
				once = true
				retalRand = false
				timer = 0
				blockHitCount = 0
				blockEndAni = true
			if timer >= 2.5:
				state = CHASE
				once = true
				retalRand = false
				timer = 0
				blockHitCount = 0
				blockEndAni = true
			if retalRand && !afterSB:
				if oldVal != blockHitCount:
					var switchChance = randi_range(1, 2)
					if switchChance == 1:
						state = CHASE
						once = true
						retalRand = false
						timer = 0
						blockHitCount = 0
						blockEndAni = true
					else:
						oldVal = blockHitCount
						
			facing_angle = Vector2(direction.z, direction.x).angle()
			
		STAGGERED:
			stagger()
			staggerTimer += delta
			if staggerTimer >= 3.5:
				unStagger()
				state = CHASE
				posture = 0
				stringCount = 1
				timerThresh = 0
				facingThresh = 0
				timer = 0
				staggerTimer = 0
				once = true
				randOnce = true
				
		DEATH:
			deathTimer += delta
			if deathTimer >= 3:
				queue_free()
			
	if blockEndAni:
		if blendVal <= 0.001: 
			blockEndAni = false
		blockEnd()
	
func cripChange():
	animation_tree.set("parameters/battleCripTrans/transition_request", "crip")
	
func battleChange():
	animation_tree.set("parameters/battleCripTrans/transition_request", "battle")

func cripIdle():
	animation_tree.set("parameters/cripIdleJogTrans/transition_request", "idle")
	
func cripJog():
	animation_tree.set("parameters/cripIdleJogTrans/transition_request", "jog")
	
func cripAtk():
	animation_tree.set("parameters/cripAtkOneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func idle():
	animation_tree.set("parameters/idleJogBlock/transition_request", "idle")
	
func jog():
	var jogVec := Vector2.ZERO
	match state:
		CHASE:
			jogVec = Vector2(0, 1)
		HOVER:
			if clockwise:
				jogVec = Vector2(1, 0)
			else:
				jogVec = Vector2(-1, 0)
	animation_tree.set("parameters/jogBlendSp/blend_position", jogVec)
	animation_tree.set("parameters/idleJogBlock/transition_request", "jog")
	
func block():
	blendVal = lerpf(blendVal, 1, 0.2)
	animation_tree.set("parameters/blockBlend/blend_amount", blendVal)
	
func blockHit():
	animation_tree.set("parameters/blockBlend/blend_amount", 1)
	animation_tree.set("parameters/blockOneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func blockEnd():
	blendVal = lerpf(blendVal, 0, 0.5)
	animation_tree.set("parameters/blockBlend/blend_amount", blendVal)
	
func blockBash():
	blendVal = lerpf(blendVal, 1, 0.2)
	animation_tree.set("parameters/blockBlend/blend_amount", blendVal)
	animation_tree.set("parameters/atkTrans/transition_request", "shieldBash")
	animation_tree.set("parameters/atkOneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func grabJog():
	animation_tree.set("parameters/idleJogBlock/transition_request", "grab")
	
func atkAbort():
	animation_tree.set("parameters/atkOneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	
func grab():
	animation_tree.set("parameters/atkTrans/transition_request", "grab")
	animation_tree.set("parameters/atkOneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func C1S1():
	animation_tree.set("parameters/atkTrans/transition_request", "combo1")
	animation_tree.set("parameters/combo1Trans/transition_request", "S1")
	animation_tree.set("parameters/atkOneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func C1S2():
	animation_tree.set("parameters/atkTrans/transition_request", "combo1")
	animation_tree.set("parameters/combo1Trans/transition_request", "S2")
	animation_tree.set("parameters/atkOneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func C1S3():
	animation_tree.set("parameters/atkTrans/transition_request", "combo1")
	animation_tree.set("parameters/combo1Trans/transition_request", "S3")
	animation_tree.set("parameters/atkOneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func C1S4():
	animation_tree.set("parameters/atkTrans/transition_request", "combo1")
	animation_tree.set("parameters/combo1Trans/transition_request", "S4")
	animation_tree.set("parameters/atkOneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func stagger():
	blendVal = lerpf(blendVal, 0, 0.2)
	animation_tree.set("parameters/blockBlend/blend_amount", blendVal)
	atkAbort()
	animation_tree.set("parameters/staggerTrans/transition_request", "stagger")
	
func unStagger():
	animation_tree.set("parameters/staggerTrans/transition_request", "norm")


func _on_Body_Entered(body):
	if body.is_in_group("player"):
		state = CHASE #Chase
		once = true
		player = body
		rotati = true


func _on_Body_Exited(body):
	if body.is_in_group("player"):
		state = IDLE
		rotati = false
		
func performC1():
		if stringCount == 1:
			C1S1()
			timerThresh = 0.9
			facingThresh = 0.5
			damage = 25
			postureDamage = 15
			hurtType = 1
		elif stringCount == 2:
			timer = 0
			C1S2()
			timerThresh = 0.9
			facingThresh = 0.5
			damage = 25
			postureDamage = 15
			hurtType = 3
		elif stringCount == 3:
			C1S3Spec = true
			timer = 0
			C1S3()
			timerThresh = 2.2
			facingThresh = 0.8
			damage = 15
			postureDamage = 10
		elif stringCount == 4:
			C1S3Spec = false
			timer = 0
			C1S4()
			timerThresh = 1.25
			facingThresh = 0.9
			damage = 50
			hurtType = 5
			postureDamage = 40
		stringCount += 1
		
func isHit(hitInfo):
	var Entityteam = hitInfo[0]
	var damageDealt = hitInfo[1]
	var postureRecieved = hitInfo[2]
	velocity = Vector3.ZERO
	if team != Entityteam:
		match state:
			CHASE:
				state = BLOCK
				blockHitCount += 1
				hitBlocked = true
				posture = posture + postureRecieved
				blockHit()
			IDLE:
				state = BLOCK
				blockHitCount += 1
				hitBlocked = true
				posture = posture + postureRecieved
				blockHit()
			HOVER: 
				state = BLOCK
				blockHitCount += 1
				hitBlocked = true
				posture = posture + postureRecieved
				blockHit()
			ATTACK:
				hp = hp - damageDealt
			STAGGERED:
				hp = hp - (damageDealt * 2)
			BLOCK:
				if !shieldBash:
					blockHit() 
					blockHitCount += 1
					hitBlocked = true
					posture = posture + postureRecieved
				else:
					hp = hp - damageDealt
					
		barVisible = true
		postureTimer = 0.0
		postLower = false
	
