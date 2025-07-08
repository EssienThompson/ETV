extends MeshInstance3D
@onready var mat = material_override

func changeDisolveVal(val):
	mat.set_shader_parameter("dissolveSlider", val)
