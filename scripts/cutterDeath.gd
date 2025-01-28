extends MeshInstance3D
@export var cutter:MeshInstance3D
@export var user : Node3D
var death := false
var mat
@export var cutPos : float
@export var endpos : float
const CUTTERMAT = preload("res://mats/cutter.tres")
var cut := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mat = get_surface_override_material(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if cutter != null:
		#material_override.set_shader_parameter("cutplane", cutter.transform)
	if death && cut != true:
		death = false
		material_override = CUTTERMAT
		if user.name == "Player":
			user.sword.material_override = CUTTERMAT
		cut = true
		
	if cut && user.name == "Player":
		material_override.set_shader_parameter("cutplane", cutter.transform)
		user.sword.material_override.set_shader_parameter("cutplane", cutter.transform)
		cutPos = lerpf(cutPos, -1.5, 0.002)
		cutter.global_position.y = cutPos
	elif cut:
		material_override.set_shader_parameter("cutplane", cutter.transform)
		cutPos = lerpf(cutPos, endpos, 0.005)
		cutter.global_position.y = cutPos
		
		
		
