extends CharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var animation_tree = $ani_scele/Armature/AnimationPlayer/AnimationTree
@onready var detectArea = $detectArea
@onready var nav = $NavigationAgent3D
@onready var armature = $ani_scele/Armature
@onready var man: MeshInstance3D = $ani_scele/Armature/Skeleton3D/man
@onready var health_bar_3d: Node3D = $HealthBar3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var hitbo: CollisionShape3D = $ani_scele/Armature/Skeleton3D/BoneAttachment3D/hitbox/CollisionShape3D

const ENEMY_TYPE = "norm"
const SPEED = 9 #7
enum State {
	IDLE,
	CHASE,
	HURT,
	ATTACK,
	STAGGERED,
	DEATH,
}
var currState : State = State.IDLE
var player
var team := 1
var damage := 0
var postureDamage := 0 
var hurtType := 0
var hp := 100
var maxHp := 100
var posture := 0 
var maxPosture := 10 
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
				velocity.x = atkDir.x * SPEED * 1.5
				velocity.z = atkDir.z * SPEED * 1.5
				
		State.STAGGERED:
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
	if barVisible:
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
		
	health_bar_3d.staggerColor()
	if hp <= 0:
		currState = State.DEATH #add death
		man.death = true
		dying = true
		#print("death reached")
		
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
				if distToPlayer <= 5:
					currState = State.ATTACK
						
			facing_angle = Vector2(direction.z, direction.x).angle() 
			
		State.ATTACK:
			var blockChance : bool
			targetPos = player.global_transform.origin
			var distToPlayer = global_transform.origin.distance_to(targetPos)
			direction = (targetPos - global_transform.origin).normalized()
			timer += delta
			if distToPlayer <= 15:
				veloZero = false
				midRange = true
			elif timer >= timerThresh:
				midRange = false
				stringCount = 3
				atkAbort()
				
			if stringCount != 2 && timer >= timerThresh:
				performAtk()
			elif stringCount >= 2 && timer >= timerThresh:
				timer = 0
				timerThresh = 0
				facingThresh = 0
				stringCount = 0
				rando = 0
				once = true
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
			
			
		State.STAGGERED:
			stagger()
			staggerTimer += delta
			if staggerTimer >= 0.63:
				stagIdle()
			
				
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
				hit()
				currState = State.HURT
				hp = hp - damageDealt
			State.IDLE:
				hit()
				currState = State.HURT
				hp = hp - damageDealt
			State.HURT: 
				hit()
				currState = State.HURT
				hp = hp - damageDealt
			State.ATTACK:
				atkAbort()
				hit()
				currState = State.HURT
				hp = hp - damageDealt
			State.STAGGERED:
				hp = hp - (damageDealt * 2)
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
		
		
func performAtk():
	if stringCount == 1:
			atk()
			timerThresh = 1.05
			facingThresh = 0.1
			damage = 5
			postureDamage = 15
			hurtType = 3
	stringCount += 1

func idle():
	animation_tree.set("parameters/idleJog/transition_request", "idle")
	
func jog():
	animation_tree.set("parameters/idleJog/transition_request", "jog")
	
func atk():
	animation_tree.set("parameters/atkOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func atkAbort():#
	animation_tree.set("parameters/atkOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	
func hit():
	animation_tree.set("parameters/hurtOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func stagger():
	animation_tree.set("parameters/staggerTrans/transition_request", "stagger")
	
func unStagger():
	animation_tree.set("parameters/staggerTrans/transition_request", "norm")
	animation_tree.set("parameters/stagIdle/transition_request", "stagger")
	
func stagIdle():
	animation_tree.set("parameters/stagIdle/transition_request", "idle")
	
