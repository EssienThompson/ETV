extends Node3D
@onready var stagger_bar: ProgressBar = $SubViewport/staggerBar
@onready var health_bar: ProgressBar = $SubViewport/staggerBar/healthBar
@onready var stagger_particles: GPUParticles2D = $SubViewport/staggerBar/staggerParticles


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stagger_particles.emitting = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setStaggerMax(max):
	stagger_bar.max_value = max
	
func setHealthMax(max):
	health_bar.max_value = max
	
func healthCurr(dmg):
	health_bar.value = dmg
		
func staggerCurr(dmg):
	stagger_bar.value = dmg
		
func fullBar():
	stagger_bar.value = stagger_bar.max_value
	health_bar.value = health_bar.max_value
	
func staggerColorRed():
	var fillBar = stagger_bar.get_theme_stylebox("fill")
	fillBar.bg_color = Color8(225, 0, 0)
	
func staggerColorOrange():
	var fillBar = stagger_bar.get_theme_stylebox("fill")
	fillBar.bg_color = Color.ORANGE
	
	

func staggerColorYellow():
	var fillBar = stagger_bar.get_theme_stylebox("fill")
	fillBar.bg_color = Color8(244, 211, 77)
	
func staggerColor():
	var progress = stagger_bar.value
	#var t = 1 - (progress/ stagger_bar.max_value)
	var rgb = 1#/t
	#rgb = clampf(rgb, 0.3, 1)
	var fillBar = stagger_bar.get_theme_stylebox("fill")
	fillBar.bg_color = Color(rgb, rgb, rgb)
	if stagger_bar.value == stagger_bar.max_value:
		stagger_particles.emitting = true
	else:
		stagger_particles.emitting = false
	
