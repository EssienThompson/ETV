extends Node3D
@onready var stagger_bar: ProgressBar = $SubViewport/staggerBar
@onready var health_bar: ProgressBar = $SubViewport/staggerBar/healthBar
@onready var stagger_particles: GPUParticles2D = $SubViewport/staggerBar/staggerParticles
@onready var damage_bar: ProgressBar = $SubViewport/staggerBar/damageBar

var timer := 0.0
var oldHealth := 0.0
var timerStart := false
var lerpTime := 0.0
var lerpDuration := 2
@export var reversed := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stagger_particles.emitting = false
	var fillBar = damage_bar.get_theme_stylebox("fill")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timerStart:
		timer += delta
		
	if timer >= 2:#time before dmg bar starts moving
		lerpTime += delta
		var progress = lerpTime/lerpDuration
		damage_bar.value = lerpf(damage_bar.value, health_bar.value, progress)
		if abs(damage_bar.value - health_bar.value) <= 0.2:
			damage_bar.value = health_bar.value
			timerStart = false
			timer = 0.0
			lerpTime = 0.0


func setStaggerMax(max):
	stagger_bar.max_value = max
	
func setHealthMax(max):
	health_bar.max_value = max
	damage_bar.max_value = max
	
func healthCurr(newHp):
	oldHealth = health_bar.value
	health_bar.value = newHp
	if oldHealth > newHp:
		timerStart = true
		timer = 0.0
	else:
		damage_bar.value = newHp
		
func staggerCurr(val):
	stagger_bar.value = val
		
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
	if reversed:
		if stagger_bar.value == 0.0:
			stagger_particles.emitting = true
		else:
			stagger_particles.emitting = false
	else:
		if stagger_bar.value == stagger_bar.max_value:
			stagger_particles.emitting = true
		else:
			stagger_particles.emitting = false
		
	
