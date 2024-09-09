extends Node3D
@onready var twist_pivot = $twistPivot
@onready var pitch_pivot = $twistPivot/pitchPivot
@onready var camera_3d = $twistPivot/pitchPivot/SpringArm3D/Camera3D
#@onready var camera_3d = $smoothCam/Camera3D
@onready var player: CharacterBody3D = $".."

var twist : float = 0
var pitch : float = 0
@onready var los = player.los
@onready var lockList = player.lockOnChoice
@onready var facingAngle = player.facing_angle
var lockOn = false
var lockRight := false
var lockleft := false
var keepLock := false
var target
var targetVal = 0
var lockSpeed = 10
var highest_dot_product = -1.0
var currHighDot := -1.0

var twistSen : float = 0.07
var pitchSen : float = 0.07

var twistAcc : float = 15
var pitchAcc : float = 15 

var pMax : float = 70
var pMin : float = -55

var targetPosition = Vector3.ZERO
var forward_vector := Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pitch = clamp(pitch, pMin, pMax)
	highest_dot_product = -1.0
	currHighDot = -1.0
	if lockOn == false:
		twist_pivot.rotation_degrees.y = lerp(twist_pivot.rotation_degrees.y, twist, twistAcc*delta)
		pitch_pivot.rotation_degrees.x = lerp(pitch_pivot.rotation_degrees.x, pitch, pitchAcc*delta) 
	else:
		twist = twist_pivot.rotation_degrees.y
		pitch = 0
		
	#print(twist)
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
		
	
	if los:
		for enemy in lockList:
			if enemy == null:
				return
			var to_enemy = (enemy.global_transform.origin - camera_3d.global_transform.origin).normalized()
			var dotProduct = forward_vector.dot(to_enemy)
			var crossProd = forward_vector.cross(Vector3.UP)
			var sideDot = crossProd.dot(to_enemy)
			if dotProduct > highest_dot_product && !lockOn:
				highest_dot_product = dotProduct
				target = enemy
				
			
			if lockleft && lockOn:
				if sideDot < 0 && dotProduct > currHighDot && dotProduct != currHighDot:
					currHighDot = dotProduct
					if enemy in lockList:
						target = enemy
					
			
			if lockRight && lockOn:
				if sideDot > 0 && dotProduct > currHighDot && dotProduct != currHighDot:
					currHighDot = dotProduct
					if enemy in lockList:
						target = enemy
					
		lockleft = false
		lockRight = false
					
	if los and lockOn:

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
	if event is InputEventMouseMotion && lockOn == false and !player.mapOpen:
		twist += -event.relative.x * twistSen
		pitch += event.relative.y * pitchSen
		
	if event is InputEventMouseMotion && lockOn:
		var sensi := 2.0
		if event.relative.x > sensi:
			lockRight = true
		if event.relative.x < -sensi:
			lockleft = true
	


func chooseTargetLeft():
	var originalDot = highest_dot_product
	for i in range(len(lockList)):
		var enemy = lockList[i]
		#if dotProduct > highest_dot_product && dotProduct < originalDot && crossProd > 0:
			#highest_dot_product = dotProduct
			#target = enemy
			
func chooseTargetRight():
	var originalDot = highest_dot_product
	highest_dot_product = -1
	for i in range(len(lockList)):
		var enemy = lockList[i]
		#if dotProduct > highest_dot_product && dotProduct < originalDot && crossProd < 0:
			#highest_dot_product = dotProduct
			#target = enemy
