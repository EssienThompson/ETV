@tool
extends MeshInstance3D
@onready var cutter:MeshInstance3D = get_node("%cutter")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if cutter != null:
		material_override.set_shader_parameter("cutplane", cutter.transform)
		
		
