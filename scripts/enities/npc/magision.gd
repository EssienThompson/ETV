extends CharacterBody3D
@onready var interactArea: Area3D = $interactArea
@onready var interactable: Node3D = $interactable
@onready var animation_tree: AnimationTree = $meshes/Armature/AnimationTree
@onready var man: MeshInstance3D = $meshes/Armature/Skeleton3D/man
@onready var hat: MeshInstance3D = $meshes/Armature/Skeleton3D/hat
@onready var man_eye: MeshInstance3D = $meshes/Armature/Skeleton3D/manEye
@onready var mask_eye: MeshInstance3D = $"meshes/Armature/Skeleton3D/Mask'Eye"
@onready var mask_mouth: MeshInstance3D = $"meshes/Armature/Skeleton3D/Mask'mouth"
@onready var n_001: MeshInstance3D = $meshes/Armature/Skeleton3D/N_001
@onready var mask_: MeshInstance3D = $"meshes/Armature/Skeleton3D/Mask'"

var playerInteractable := false
var headT := false
var turnVal := 0.0
var timer := 0.0
var player
var interact
var diaID : String
var dying := false
var setDeath := false




func _ready() -> void:
	interactArea.connect("body_entered", Callable(self, "body_entered"))
	interactArea.connect("body_exited", Callable(self, "body_exited"))
	Dialogic.signal_event.connect(dialogicSignals)
	#print(get_tree().current_scene.name)
	

func _process(delta):
	if headT:
		if turnVal < 1:
			turnVal = maxf(turnVal + 2*delta, 1.0)
	elif headT == false:
		if turnVal > 0.05:
			turnVal = maxf(turnVal - 2*delta, 0.0)
			
	headTurn(turnVal)
			
	if playerInteractable && !dying:
		interactable.visible = true
	else:
		interactable.visible = false
		
	if Input.is_action_just_pressed("interect") && playerInteractable && player.isTalking == false && !dying:
		match diaID:
			"rest":
				if Events.magiOpt == 0:
					Dialogic.start("magisionTutor")
				elif Events.magiOpt == 1:
					Dialogic.start("magiTutRest")
			
			"tutCombat":
				Dialogic.start("magiTutCombat")
				
			"tutRelic":
				Dialogic.start("magiTutRelic")
				
			"tutCombat4":
				Dialogic.start("magiTutElite")
				
			
		player.isTalking = true
		headT = true
		
	if setDeath:
		timer += delta
		if timer >= 0.7:
			timer = 0
			setDeath = false
			man.death = true
			hat.death = true
			man_eye.death = true
			mask_eye.death = true
			mask_mouth.death = true
			mask_.death = true
			n_001.death = true
			dying = true
		
	if dying:
		timer += delta
		if timer >= 3.4:
			queue_free()

func body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		playerInteractable = true
		player = body

func body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		playerInteractable = false
		
		
func headTurn(val : float):
	animation_tree.set("parameters/headBlend/blend_amount", val)
	
func clickFin():
	animation_tree.set("parameters/clickOneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func maskMou(val : float):
	animation_tree.set("parameters/maskMouBlend/blend_amount", val)
	
func resetMou():
	animation_tree.set("parameters/maskMouTrans/transition_request", "reset")
	
func smile():
	animation_tree.set("parameters/maskMouTrans/transition_request", "smile")
	
func frown():
	animation_tree.set("parameters/maskMouTrans/transition_request", "frown")
	
func neutral(): 
	animation_tree.set("parameters/maskMouTrans/transition_request", "neutral")
	
func annoy(): 
	animation_tree.set("parameters/maskMouTrans/transition_request", "annoy")
	
func shocked(): 
	animation_tree.set("parameters/maskMouTrans/transition_request", "shocked")
	
func maskEye(val : float):
	animation_tree.set("parameters/maskEyeBlend/blend_amount", val)
	
func resetEye():
	animation_tree.set("parameters/maskEyeTrans/transition_request", "reset")
	
func eyeClosed():
	animation_tree.set("parameters/maskEyeTrans/transition_request", "closed")
	
func eyeAgro():
	animation_tree.set("parameters/maskEyeTrans/transition_request", "agro")
	
	
func dialogicSignals(sig):
	if sig == "stopTalk":
		headT = false
		
	elif sig == "rockDrop":
		clickFin()
		setDeath = true
		
	elif sig == "magiSmile":
		smile()
		
	elif sig == "magiFrown":
		frown()
		
	elif sig == "magiNeutral":
		neutral()
		
	elif sig == "magiResetMou":
		resetMou()
		
	elif sig == "magiResetEye":
		resetEye()
		
	elif sig == "magiClosed":
		eyeClosed()
		
	elif sig == "magiAnnoy":
		annoy()
	
	elif sig == "magiShocked":
		shocked()
		
	elif sig == "magiAgro":
		eyeAgro()
		
	
