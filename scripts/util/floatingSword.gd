extends Node3D

@export var user : Node3D
@export var restPoint : Node3D
@export var attackOffset : Vector3
@export var restDist : float = 0.5
#@export var target : Node3D
@export var test : Node3D
@export var test2 : Node3D

@onready var sword_step_tar: Node3D = $cont/swordStepTar
@onready var ray_cast_3d: RayCast3D = $cont/swordStepTar/RayCast3D
@onready var sphere_emit: GPUParticles3D = $sphereEmit

@onready var hitb : hitbox = $hitbox
@onready var cont: Node3D = $cont

var startAtk := false
var isAtking : bool = false
var startParry := false
var isParried : bool = false
var isStuck := false
var fin1 := false
var fin2 := false
var timer := 0.0
var stuckPos
var attackTween
var target : Node3D
var tarHol

func _process(delta: float) -> void:
	if global_position.distance_to(restPoint.global_position) > restDist && !isAtking && !startAtk && !isParried && !startParry && !isStuck:
		rest()
		cont.isAtking = false
		ray_cast_3d.resetPos()
		
	#if Input.is_action_just_pressed("attack") && !isAtking && !startAtk && !isParried && !startParry && !isStuck:
		#startAtk = true
		#cont.isAtking = true
		
	target = user.target
	
	if startAtk:
		timer += delta
		if timer <= 1.0:
			sphere_emit.emitting = true
			if target == null:
				startAtk = false
				timer = 0.0
				sphere_emit.emitting = false
			else:
				if "lockOn" in target:
					point(target.lockOn.global_position)
					tarHol = target.lockOn.global_position
				else:
					point(target.global_position)
					tarHol = target.global_position
		else:
			sphere_emit.emitting = false
			hitb.active = true
			startAtk = false
			attack(tarHol)
			
	if isAtking: #maybe phys process
		var space_state = get_world_3d().direct_space_state
		var origin = global_transform.origin
		var enemyPos = tarHol#target.global_transform.origin
		var enemyDir = (enemyPos - origin).normalized()
		var distToEnemy = origin.distance_to(enemyPos)
		var end = origin + enemyDir * distToEnemy
		var colliMask: int =  (1 << 0) | (1 << 3)
		var query = PhysicsRayQueryParameters3D.create(origin, end, colliMask)
		var result = space_state.intersect_ray(query)
		#DrawLine3d.DrawLine(origin, end, Color(0, 1, 0), 2)
		if result and result.get("collider").is_in_group("wall"):
			var pos = result.get("position")
			var distToColl = origin.distance_to(pos)
			if distToColl <= 1.5:
				if attackTween:
					attackTween.kill()
					attackTween = null
				timer = 0.0
				stuckPos = pos
				isStuck = true
			
	if startParry:
		parried(target.global_position)
		isAtking = false
		startAtk = false
		startParry = false
			
	if isStuck:
		timer += delta
		global_position = stuckPos
		if timer >= 3.0:
			isStuck = false
			timer = 0.0
			
	if fin1 && fin2:
		isParried = false
		fin1 = false
		fin2 = false
			
	
func rest():
	var restPos = restPoint.global_position
	var restRot = restPoint.global_basis.get_rotation_quaternion()
	var interp = global_basis.get_rotation_quaternion().slerp(restRot, 0.5)
	var interpBasis = Basis(interp).orthonormalized()
	var scaleB = interpBasis.scaled(transform.basis.get_scale()) 
	transform = Transform3D(scaleB, global_position)
	#global_basis = interpBasis
	var t = get_tree().create_tween()
	t.tween_property(self, "global_position", restPos, 0.5).set_ease(Tween.EASE_OUT)
	#t.tween_property(self, "transform.basis", Basis(restQuat), 0.1).set_ease(Tween.EASE_IN)
	
func point(targetPos):
	var directionToTarget = ((targetPos - global_position).normalized())
	var swordFor = Vector3.DOWN
	var rotQuat = Quaternion(swordFor, directionToTarget)
	var interp = global_basis.get_rotation_quaternion().slerp(rotQuat, 0.1)
	var interpBasis = Basis(interp).orthonormalized()
	var scaleB = interpBasis.scaled(transform.basis.get_scale()) 
	transform = Transform3D(scaleB, global_position) 
	
func attack(targetPos):
	isAtking = true
	var directionToTarget = ((targetPos - global_position).normalized())
	var directionFromTarget = (global_position - targetPos).normalized()
	var negPos = global_position + directionFromTarget * 2
	var endPos = targetPos + directionToTarget * 2
	#test.global_position = negPos
	if attackTween:
		attackTween.kill()
		attackTween = null
	var t = get_tree().create_tween()
	t.tween_property(self, "global_position", negPos, 0.25).set_ease(Tween.EASE_OUT)
	#t.tween_callback(func(): print("First tween complete"))
	t.chain().tween_property(self, "global_position", endPos, 0.1).set_ease(Tween.EASE_IN)
	#t.tween_callback(func(): print("Second tween complete"))
	attackTween = t
	t.tween_callback(func(): isAtking = false)
	t.tween_callback(func(): timer = 0.0)
	t.tween_callback(func(): hitb.active = false)
	#t.tween_callback(func(): startParry = true)
	if isStuck: 
		t.kill()
	#t.play()
	
func parried(targetPos):
	isParried = true
	var directionFromTarget = (global_position - targetPos).normalized()
	var zRan = randf_range(120.0, 150.0)
	var zRan2 = randf_range(-15.0, 10.0)
	var yRan = randf_range(-75.0, -150.0)
	var xRan = randf_range(-7.0, -3.0)
	var xRan2 = randf_range(-7.0, -3.0)
	var offsetMov = remap(yRan, -75.0, -150.0, -0.5, 0.5)
	var rot = Vector3(xRan, yRan, zRan)
	var rot2 = Vector3(xRan2, yRan, zRan2)
	cont.parried = true
	cont.parriedOffset = offsetMov
	var halfway = (global_position + sword_step_tar.global_position)/2 + Vector3(0,3,0)
	var halfwayBot = (global_position + halfway)/2
	var t = get_tree().create_tween()
	var t2 = get_tree().create_tween()
	t.tween_property(self, "global_rotation_degrees", rot, 0.25).set_ease(Tween.EASE_OUT)
	t.chain().tween_property(self, "global_rotation_degrees", rot2, 0.5).set_ease(Tween.EASE_OUT)
	
	#t2.tween_property(self, "global_position", halfwayBot, 1).set_ease(Tween.EASE_OUT)
	t2.tween_property(self, "global_position", halfway, 0.25).set_ease(Tween.EASE_IN_OUT)
	t2.chain().tween_property(self, "global_position", sword_step_tar.global_position, 0.5).set_ease(Tween.EASE_IN)
	
	t.tween_callback(func(): fin1 = true)
	t2.tween_callback(func(): fin2 = true)
	t.tween_callback(func(): cont.parried = false)
	t.tween_callback(func(): cont.parriedOffset = 0.0)
	


func _on_stuck_box_body_entered(body: Node3D) -> void:
	if isAtking or isParried:
		if attackTween:
			attackTween.kill()
			attackTween = null
		stuckPos = global_position
		timer = 0.0
		hitb.active = false
		isAtking = false
		isParried = false
		isStuck = true
		
func startAttack():
	if !isAtking && !startAtk && !isParried && !startParry && !isStuck && target != null:
		startAtk = true
		cont.isAtking = true
