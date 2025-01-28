extends Node3D
@onready var twist_pivot = $twistPivot
@onready var pitch_pivot = $twistPivot/pitchPivot
@onready var camera_3d = $twistPivot/pitchPivot/SpringArm3D/Camera3D
@onready var spring_arm_3d: SpringArm3D = $twistPivot/pitchPivot/SpringArm3D
#@onready var camera_3d = $smoothCam/Camera3D
@onready var player: CharacterBody3D = $".."

const DEADZONE = 0.1

var twist : float = 0
var pitch : float = 0
@onready var los = player.los
@onready var lockList = player.lockOnChoice
@onready var facingAngle = player.facing_angle
var lockOn := false
var lockRight := false
var lockleft := false
var keepLock := false
var target
var leftTar
var rightTar
var targetVal := 0
var lockSpeed := 10
var highest_dot_product := -1.0
var leftDot := -1.0
var rightDot := 1.0
var timer := 0.0
var lockDelay := false

var twistSen : float = 0.07
var pitchSen : float = 0.07
var conTwistSen : float = 1
var conPitchSen : float = 1

var twistAcc : float = 15
var pitchAcc : float = 15 

var pMax : float = 70
var pMin : float = -55

var targetPosition := Vector3.ZERO
var forward_vector := Vector3.ZERO


var shakeStrength: float = 0.0
var shakeDecay := 2.0
var maxShakeAngle := 5.0

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if lockOn == false:
		twist_pivot.rotation_degrees.y = lerp(twist_pivot.rotation_degrees.y, twist, twistAcc*delta)
		pitch_pivot.rotation_degrees.x = lerp(pitch_pivot.rotation_degrees.x, pitch, pitchAcc*delta) 
	else:
		twist = twist_pivot.rotation_degrees.y
		pitch = 0
		
	#print(twist)
					
	if los and lockOn and target != null:
		var rotated_basis = target.global_transform.looking_at(twist_pivot.global_transform.origin, Vector3.UP).basis.orthonormalized()
		pitch_pivot.rotation.x = lerp_angle(pitch_pivot.rotation.x + 0.075, 0, delta * lockSpeed)
		#if targetVal <= 1:
			#targetVal += lockSpeed*delta
		
		#twist_pivot.global_transform.basis = twist_pivot.global_transform.basis.slerp(rotated_basis, targetVal)
		var normalized_basis = twist_pivot.global_transform.basis.orthonormalized()
		var slerped_basis = normalized_basis.slerp(rotated_basis, delta * lockSpeed)
		twist_pivot.global_transform.basis = slerped_basis
		
		#twist_pivot.global_transform.basis = twist_pivot.global_transform.basis.slerp(rotated_basis, delta * lockSpeed)
	else:
		twist_pivot.rotation.x = lerp_angle(twist_pivot.rotation.x, 0, delta*lockSpeed)
		twist_pivot.rotation.z = lerp_angle(twist_pivot.rotation.z, 0, delta*lockSpeed)
	
		

func _input(event):
	if (event is InputEventMouseMotion) && lockOn == false and !player.mapOpen:
		twist += -event.relative.x * twistSen
		pitch += event.relative.y * pitchSen
		
	#if (event is InputEventJoypadMotion) && lockOn == false and !player.mapOpen:
		#match event.axis:
			#2:
				#if abs(event.axis_value) > DEADZONE:
					#twist += -event.axis_value * 2
			#
			#3:
				#if abs(event.axis_value) > DEADZONE:
					#pitch += event.axis_value * 2
		
	if event is InputEventMouseMotion && lockOn:
		var sensi := 5.0
		if event.relative.x > sensi:
			lockRight = true
		if event.relative.x < -sensi:
			lockleft = true
	

func zero():
	twist = 0
	pitch = 0
	

func _process(delta):
	var input_dir = Input.get_vector("rightJoyLeft", "rightJoyRight", "rightJoyUp", "rightJoyDown")
	if (abs(input_dir.x) > DEADZONE) && lockOn == false and !player.mapOpen:
		twist += -input_dir.x * conTwistSen
	if (abs(input_dir.y) > DEADZONE) && lockOn == false and !player.mapOpen:
		pitch += input_dir.y * conPitchSen
		
	if (abs(input_dir.x) > DEADZONE) && lockOn: 
		var conSensi := 0.3
		if input_dir.x > conSensi:
			lockRight = true
			
		if input_dir.x < -conSensi:
			lockleft = true
			
	#if Input.is_action_just_pressed("test"):
		#startShake(0.50, 0.25)
		
	if shakeStrength > 0:
		var twistShake = randf_range(-1, 1) * deg_to_rad(maxShakeAngle) * shakeStrength
		var pitchShake = randf_range(-1, 1) * deg_to_rad(maxShakeAngle) * shakeStrength
		
		spring_arm_3d.rotation_degrees.x = rad_to_deg(pitchShake)
		spring_arm_3d.rotation_degrees.y = rad_to_deg(twistShake)
		
		shakeStrength = maxf(shakeStrength - shakeDecay*delta, 0.0)
	else:
		spring_arm_3d.rotation_degrees = Vector3.ZERO
		
	
	pitch = clamp(pitch, pMin, pMax)
	highest_dot_product = -1.0
	rightDot = 1.0
	leftDot = -1.0
	
	los = player.los
	lockList = player.lockOnChoice
	forward_vector = -camera_3d.global_transform.basis.z.normalized()
	if Input.is_action_just_pressed("lock_on") and los and !lockList.is_empty() && target != null:
		lockOn = !lockOn
		#targetVal = 0
		
	if !los or lockList.is_empty():
		lockOn = false
	if target != null:
		var chk = 0
		for enemy in lockList:
			if target == enemy or keepLock:
				chk = 1
		if chk == 0:
			lockOn = false
			target = null
		keepLock = false
		
	if player.floored:
		lockOn = false
		
	if leftTar:
		if leftTar.dying:
			leftTar = null
		
	if rightTar:
		if rightTar.dying:
			rightTar = null
		
	
	if los:
		for enemy in lockList:
			if enemy == null:
				return
			var to_enemy = (enemy.global_transform.origin - camera_3d.global_transform.origin).normalized()
			var dotProduct = forward_vector.dot(to_enemy)
			var crossProd = forward_vector.cross(Vector3.UP)
			var sideDot = crossProd.dot(to_enemy)
			var toTar := Vector3.ZERO
			var tarDot := 0.0
			if target:
				toTar = (target.global_transform.origin - camera_3d.global_transform.origin).normalized() #will break if load level and enemy not gone
				tarDot = crossProd.dot(toTar)
				
			if dotProduct > highest_dot_product && !lockOn:
				highest_dot_product = dotProduct
				target = enemy
				
			if sideDot < tarDot && sideDot > leftDot && enemy != target: #remove ()
					leftDot = sideDot
					if enemy in lockList:
						leftTar = enemy
				
			if sideDot > tarDot && sideDot < rightDot && enemy != target:
					rightDot = sideDot
					if enemy in lockList:
						rightTar = enemy
						
			#print(rightTar," right")
			#print(leftTar, " left")
			#print(sideDot," ",enemy.name)
		if lockleft && lockOn && lockDelay == false && leftTar != null:
			target = leftTar
			lockDelay = true
					
			
		if lockRight && lockOn && lockDelay == false && rightTar != null:
			target = rightTar
			lockDelay = true
			
					
		lockleft = false
		lockRight = false
		
	if lockDelay:
		timer += delta
		
	if timer >= 0.25:
		lockDelay = false
		timer = 0.0
		

func startShake(intensit:float, dur:float):
	shakeStrength = intensit
	shakeDecay = intensit/dur




#func chooseTargetLeft():
	#var originalDot = highest_dot_product
	#for i in range(len(lockList)):
		#var enemy = lockList[i]
		#if dotProduct > highest_dot_product && dotProduct < originalDot && crossProd > 0:
			#highest_dot_product = dotProduct
			#target = enemy
			
#func chooseTargetRight():
	#var originalDot = highest_dot_product
	#highest_dot_product = -1
	#for i in range(len(lockList)):
		#var enemy = lockList[i]
		#if dotProduct > highest_dot_product && dotProduct < originalDot && crossProd < 0:
			#highest_dot_product = dotProduct
			#target = enemy
