extends Node3D

@export var user : Node3D
@export var restPoint : Node3D
@export var attackOffset : Vector3
@export var restDist : float = 0.5
@export var target : Node3D
#@export var test : Node3D

@onready var hitb : hitbox = $hitbox
var startAtk := false
var isAtking : bool = false
var timer := 0.0
var tarHol

func _process(delta: float) -> void:
	if global_position.distance_to(restPoint.global_position) > restDist && !isAtking && !startAtk:
		rest()
		
	if Input.is_action_just_pressed("attack") && !isAtking && !startAtk:
		startAtk = true
		point(target.global_position)
		#look_at(target.global_position)
	
	if startAtk:
		timer += delta
		if timer <= 1.0:
			point(target.global_position)
			tarHol = target.global_position
		else:
			startAtk = false
			attack(tarHol)
	
func rest():
	var restPos = restPoint.global_position
	var restRot = restPoint.global_basis.get_rotation_quaternion()
	var interp = global_basis.get_rotation_quaternion().slerp(restRot, 0.25)
	var interpBasis = Basis(interp).orthonormalized()
	var scaleB = interpBasis.scaled(transform.basis.get_scale()) 
	transform = Transform3D(scaleB, global_position)
	#global_basis = interpBasis
	var t = get_tree().create_tween()
	t.tween_property(self, "global_position", restPos, 0.25).set_ease(Tween.EASE_OUT)
	#t.tween_property(self, "transform.basis", Basis(restQuat), 0.1).set_ease(Tween.EASE_IN)
	
func point(targetPos):
	var directionToTarget = (targetPos - global_position).normalized()
	var swordFor = Vector3.DOWN
	var rotQuat = Quaternion(swordFor, directionToTarget)
	var interp = global_basis.get_rotation_quaternion().slerp(rotQuat, 0.25)
	var interpBasis = Basis(interp).orthonormalized()
	var scaleB = interpBasis.scaled(transform.basis.get_scale()) 
	transform = Transform3D(scaleB, global_position)
	
func attack(targetPos):
	isAtking = true
	var directionFromTarget = (global_position - targetPos).normalized()
	var negPos = global_position + directionFromTarget * 2
	#test.global_position = negPos
	var t = get_tree().create_tween()
	t.tween_property(self, "global_position", negPos, 0.25).set_ease(Tween.EASE_OUT)
	#t.tween_callback(func(): print("First tween complete"))
	t.chain().tween_property(self, "global_position", targetPos, 0.1).set_ease(Tween.EASE_IN)
	#t.tween_callback(func(): print("Second tween complete"))
	t.tween_callback(func(): isAtking = false)
	t.tween_callback(func(): timer = 0.0)
	#t.play()
	
	
