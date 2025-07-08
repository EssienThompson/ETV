extends Node3D

@onready var sword: Node3D = $".."
@onready var offset := global_position - sword.global_position
var parriedOffset := 0.0
var parried := false
var isAtking := false

func _process(delta: float) -> void:
	if !parried:
		global_position = sword.global_position + offset# * Vector3(1,0,1)
		if !isAtking:
			global_rotation_degrees.y = sword.global_rotation_degrees.y
		else: 
			var target = sword.target
			if target != null:
				var directionToTarget = ((target.global_position - global_position).normalized())
				var swordFor = Vector3.RIGHT
				var rotQuat = Quaternion(swordFor, directionToTarget)
				var interp = global_basis.get_rotation_quaternion().slerp(rotQuat, 0.1)
				var interpBasis = Basis(interp).orthonormalized()
				var scaleB = interpBasis.scaled(transform.basis.get_scale()) 
				transform = Transform3D(scaleB, global_position)
	else:
		global_position = sword.global_position + offset + Vector3(parriedOffset,0,0)# * Vector3(1,0,1)
