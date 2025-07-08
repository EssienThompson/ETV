extends Node3D
@onready var stagger_bar: ProgressBar = $SubViewport/staggerBar
@onready var health_bar: ProgressBar = $SubViewport/staggerBar/healthBar
@onready var stagger_particles: GPUParticles2D = $SubViewport/staggerBar/staggerParticles
@onready var damage_bar: ProgressBar = $SubViewport/staggerBar/damageBar

var timer := 0.0
var oldHealth := 0.0
var timerStart := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stagger_particles.emitting = false
	var fillBar = damage_bar.get_theme_stylebox("fill")
	print(fillBar.bg_color)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timerStart:
		timer += delta
		
	if timer >= 2.5:
		print(damage_bar.value)
		damage_bar.value = lerpf(damage_bar.value, health_bar.value, 0.02)
		if abs(damage_bar.value - health_bar.value) <= 0.3:
			damage_bar.value = health_bar.value
			timerStart = false
			timer = 0.0

func setStaggerMax(max):
	stagger_bar.max_value = max
	
func setHealthMax(max):
	health_bar.max_value = max
	damage_bar.max_value = max
	
func healthCurr(dmg):
	oldHealth = health_bar.value
	health_bar.value = dmg
	if oldHealth > dmg:
		timerStart = true
		timer = 0.0
		print("wok")
	else:
		damage_bar.value = dmg
		
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
	
