extends CharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var animation_tree = $zomb/Armature/Skeleton3D/AnimationPlayer/AnimationTree
@onready var detectArea = $detectArea
@onready var nav = $NavigationAgent3D
@onready var armature = $zomb/Armature
@onready var man: MeshInstance3D = $zomb/Armature/Skeleton3D/man
@onready var health_bar_3d: Node3D = $CollisionShape3D/HealthBar3D
@onready var sparks: GPUParticles3D = $zomb/Armature/Skeleton3D/sword/sparks

const ENEMY_TYPE = "norm"
const SPEED = 7 #7
enum State {
	IDLE,
	CHASE,
	HURT,
	ATTACK,
	STAGGERED,
	BLOCK,
	DEATH,
}
var currState : State = State.IDLE
var player
var team := 1
var damage := 0
var postureDamage := 0 
var hurtType := 0
var hp := 150.0
var maxHp := 150.0
var posture := 0.0
var maxPosture := 30.0 
var blendVal := 0.0

var direction := Vector3.ZERO
var targetPos := Vector3.ZERO
var atkDir:= Vector3.ZERO
var attackerDir := Vector3.ZERO
var facing_angle : float
var timer := 0.0
var timerThresh := 0.0
var facingThresh := 0.0
var rando := 0.0
var staggerTimer := 0.0
var barTimer := 0.0
var deathTimer := 0.0
var postureTimer := 0.0
var postLowTimer := 0.0
var stringCount := 0
var blockHitCount := 0
var midRange := false
var veloZero := false
var atkMove := false
var atk1var := false
var atk2var := false
var blockEndAni := false
var blockRepeat := false
var once := false
var rotati := false
var dying := false
var barVisible := false
var postLower := false

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	match currState:
		State.IDLE:
			velocity.x = 0
			velocity.z = 0
		State.CHASE:
			velocity.x = direction.x * SPEED 
			velocity.z = direction.z * SPEED
		
		State.ATTACK:
			if veloZero:
				velocity.x = 0
				velocity.z = 0
			elif atkMove:
				velocity.x = atkDir.x * SPEED 
				velocity.z = atkDir.z * SPEED 
				
		State.STAGGERED:
			velocity.x = 0
			velocity.z = 0
			
		State.BLOCK:
			velocity.x = 0
			velocity.z = 0
			
		State.HURT:
			velocity.x = -attackerDir.x * SPEED/2
			velocity.z = -attackerDir.z * SPEED/2
			
		State.DEATH:
			velocity.x = 0
			velocity.z = 0
			
	move_and_slide()
	var rot
	if rotati == true:
		rot = facing_angle - global_rotation.y
		armature.rotation.y = lerp_angle(armature.rotation.y, rot, 0.08)
	else:
		armature.rotation.y = lerp_angle(armature.rotation.y, facing_angle, 0.08)
	
func _process(delta):
	health_bar_3d.healthCurr(hp)
	health_bar_3d.staggerCurr(posture)
	health_bar_3d.staggerColor()
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
		else:
			postLower = false
		
	if postLower:
		postLowTimer += delta
		if postLowTimer >= 0.1:
			posture = posture - (maxPosture*0.01)
			postLowTimer = 0.0
			if posture <= 0:
				posture = 0
	
	if posture >= maxPosture:
		currState = State.STAGGERED
		#health_bar_3d.staggerColorRed()
	#elif posture >= maxPosture/2:
		#health_bar_3d.staggerColorOrange()
	#else:
		#health_bar_3d.staggerColorYellow()
		
	if hp <= 0:
		currState = State.DEATH 
		man.death = true
		dying = true
		
	match currState: 
		State.IDLE:
			idle()
			
		State.CHASE:
			jog()
			if player == null:
				return
			else:
				targetPos = player.global_transform.origin
				nav.target_position = targetPos
				direction = (nav.get_next_path_position() - global_transform.origin).normalized()
				var distToPlayer = global_transform.origin.distance_to(targetPos)
				if distToPlayer <= 4:
					rando = randi_range(1, 2)
					if rando == 2 && blockRepeat == false:
						currState = State.BLOCK
					else:
						currState = State.ATTACK
						rando = 0
						once = true
						
			facing_angle = Vector2(direction.z, direction.x).angle() 
			
		State.ATTACK:
			var blockChance : bool
			targetPos = player.global_transform.origin
			var distToPlayer = global_transform.origin.distance_to(targetPos)
			direction = (targetPos - global_transform.origin).normalized()
			timer += delta
			if distToPlayer <= 3.3:
				veloZero = true
				midRange = false
			elif distToPlayer <= 7.5:
				veloZero = false
				midRange = true
			elif timer >= timerThresh:
				midRange = false
				stringCount = 3
				atkAbort()
			
			if once:
				rando = randi_range(1, 2)
				once = false
				
			if stringCount != 3 && timer >= timerThresh:
				performAtk()
			elif stringCount >= 3 && timer >= timerThresh:
				timer = 0
				timerThresh = 0
				facingThresh = 0
				stringCount = 0
				rando = 0
				once = true
				blockRepeat = false
				currState = State.CHASE
				
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
			
		State.BLOCK:
			block()
			timer += delta
			blockEndAni = false
			if blockRepeat == true:
				currState = State.CHASE
				once = true
			targetPos = player.global_transform.origin
			var distToPlayer = global_transform.origin.distance_to(targetPos)
			direction = (targetPos - global_transform.origin).normalized()
			if distToPlayer >= 4.5 && timer >= 1.4:#i chose 1.4 just casue
				currState = State.CHASE 
				blockHitCount = 0
				blockRepeat = true
				timer = 0
				blockEndAni = true
			if timer >= 2.5:
				currState = State.CHASE
				blockHitCount = 0
				blockRepeat = true
				timer = 0
				blockEndAni = true
			facing_angle = Vector2(direction.z, direction.x).angle()
			
		State.STAGGERED:
			stagger()
			staggerTimer += delta
			if staggerTimer >= 3:
				unStagger()
				currState = State.CHASE
				posture = 0
				timerThresh = 0
				facingThresh = 0
				timer = 0
				staggerTimer = 0
				
		State.HURT:
			timer += delta
			if timer >= 0.5:
				currState = State.CHASE
				timerThresh = 0
				facingThresh = 0
				timer = 0
				
		State.DEATH: 
			deathTimer += delta
			if deathTimer >= 3:
				queue_free()
		
	if blockEndAni:
		if blendVal <= 0.001: 
			blockEndAni = false
		blockEnd()

func _ready():
	detectArea.connect("body_entered", Callable(self, "_on_Body_Entered"))
	detectArea.connect("body_exited", Callable(self, "_on_Body_Exited"))
	hp = maxHp
	health_bar_3d.setStaggerMax(maxPosture)
	health_bar_3d.setHealthMax(maxHp)
	health_bar_3d.fullBar()
	
func isHit(hitInfo):
	var Entityteam = hitInfo[0]
	var damageDealt = hitInfo[1]
	var postureRecieved = hitInfo[2]
	var entityHurtType = hitInfo[3]
	var entityOrigin = hitInfo[4]
	velocity.x = 0
	velocity.z = 0
	if team != Entityteam:
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
				timer -= 0.25
				if blockHitCount == 1:
					blockHit1()
				else:
					blockHit2()
					blockHitCount = 0
				posture = posture + postureRecieved
				sparksActi()
		attackerDir = (entityOrigin - global_transform.origin).normalized()
		facing_angle = Vector2(attackerDir.z, attackerDir.x).angle()
		barVisible = true
		postureTimer = 0
		postLower = false


func _on_Body_Entered(body):
	if body.is_in_group("player"):
		currState = State.CHASE #Chase
		rotati = true
		once = true
		player = body

func _on_Body_Exited(body):
	if body.is_in_group("player"):
		currState = State.IDLE
		rotati = false
		
func hurtAni(ht):
	if ht == 1:
		hit1()
	elif ht == 2:
		hit2()
	elif ht == 3:
		hit3()
	elif ht == 4 or ht == 5:
		hit4()
		
func performAtk():
	if stringCount == 1:
			atk1()
			timerThresh = 0.9
			facingThresh = 0.55
			damage = 10
			postureDamage = 15
			hurtType = 1
	elif stringCount == 2 and rando !=2:
			timer = 0
			atk2()
			timerThresh = 0.85
			facingThresh = 0.5
			damage = 15
			postureDamage = 15
			hurtType = 3
	stringCount += 1
	
func sparksActi():
	sparks.restart()
	sparks.emitting = true
	

func idle():
	animation_tree.set("parameters/idleJog/transition_request", "idle")
	
func jog():
	var blend := Vector2(0,1)
	animation_tree.set("parameters/JogSpace2D/blend_position", blend)
	animation_tree.set("parameters/idleJog/transition_request", "jog")
	
func atk1():
	animation_tree.set("parameters/atkTrans/transition_request", "atk1")
	animation_tree.set("parameters/atkOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func atk2():
	animation_tree.set("parameters/atkTrans/transition_request", "atk2")
	animation_tree.set("parameters/atkOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func atkAbort():#
	animation_tree.set("parameters/atkOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	
func block():
	blendVal = lerpf(blendVal, 1, 0.2)
	animation_tree.set("parameters/blockBlend/blend_amount", blendVal)
	
func blockEnd():
	blendVal = lerpf(blendVal, 0, 0.5)
	animation_tree.set("parameters/blockBlend/blend_amount", blendVal)
	
func blockHit1():
	animation_tree.set("parameters/blockBlend/blend_amount", 1)
	animation_tree.set("parameters/blockTrans/transition_request", "blockHit1")
	animation_tree.set("parameters/blockOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func blockHit2():
	animation_tree.set("parameters/blockBlend/blend_amount", 1)
	animation_tree.set("parameters/blockTrans/transition_request", "blockHit2")
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
	
func stagger():
	animation_tree.set("parameters/staggerTrans/transition_request", "stagger")
	
func unStagger():
	animation_tree.set("parameters/staggerTrans/transition_request", "norm")
