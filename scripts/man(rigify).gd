extends Node3D


@onready var animation_tree = $rig/Skeleton3D/AnimationPlayer/AnimationTree
@onready var player: CharacterBody3D = $".."
@onready var cam_root = $"../camRoot"
@onready var dodgeVec = player.input_dir
@onready var swordObj = $rig/Skeleton3D/BoneAttachment3D/swordCont
@onready var sparks: GPUParticles3D = $sparks
@onready var animation_player: AnimationPlayer = $rig/Skeleton3D/AnimationPlayer
#@onready var sp1: Marker3D = $rig/Skeleton3D/BoneAttachment3D/swordCont/sP1
@onready var sp1: Marker3D = $sP1
#@onready var sp2: Marker3D = $Armature/sP2
#@onready var sp3: Marker3D = $Armature/sP3
#@onready var sp4: Marker3D = $Armature/sP4
@onready var line: GPUParticles3D = $sparks/line


var blendVal := 0.0
var tes

#var blendAmt := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	#tes = animation_tree.get("parameters/walkJog/current_state")
	#blendAmt = animation_tree.get("parameters/blockBlends/blend_amount")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta): # add dodge animations to tree
	if player.is_on_floor():
		animation_tree.set("parameters/fallAtk/blend_amount", 0.0)
	
	
func fallSword():
	#animation_tree.set("parameters/fallAtk/blend_amount", 0)
	animation_tree.set("parameters/fallMoveSword/transition_request", "fall")
	
func jumpSword():
	animation_tree.set("parameters/blockBlends/blend_amount", 0)
	animation_tree.set("parameters/jumpSword/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	animation_tree.set("parameters/fallMoveSword/transition_request", "fall")
	
func idle():
	animation_tree.set("parameters/idleMove/transition_request", "idle")
	
func idleSword():
	#animation_tree.set("parameters/blockBlends/blend_amount", 0)
	animation_tree.set("parameters/fallMoveSword/transition_request", "move")
	animation_tree.set("parameters/idleMoveSword/transition_request", "idle")
	
func walk():
	animation_tree.set("parameters/idleMove/transition_request", "move")
	animation_tree.set("parameters/runToggle/transition_request", "jog")
	animation_tree.set("parameters/walkJog/transition_request", "walk")
	
func walkSword():
	#animation_tree.set("parameters/blockBlends/blend_amount", 0)
	animation_tree.set("parameters/fallMoveSword/transition_request", "move")
	animation_tree.set("parameters/idleMoveSword/transition_request", "move")
	animation_tree.set("parameters/runToggleSword/transition_request", "jog")
	animation_tree.set("parameters/walkJogSword/transition_request", "walk")

func jogstr():
	animation_tree.set("parameters/idleMove/transition_request", "move")
	animation_tree.set("parameters/runToggle/transition_request", "jog")
	animation_tree.set("parameters/walkJog/transition_request", "jog")
	
func jogSword():
	#animation_tree.set("parameters/blockBlends/blend_amount", 0)
	dodgeVec = player.input_dir
	var dodgeDir = Vector2(dodgeVec.x, -dodgeVec.y) #need to interpolate
	var unlocked = Vector2(0, 1)
	var curBlend = animation_tree.get("parameters/jogSword/blend_position")
	if cam_root.lockOn == true:
		animation_tree.set("parameters/jogSword/blend_position", lerp(curBlend, dodgeDir, 0.20))
	else:
		animation_tree.set("parameters/jogSword/blend_position", unlocked)
	animation_tree.set("parameters/fallMoveSword/transition_request", "move")
	animation_tree.set("parameters/idleMoveSword/transition_request", "move")
	animation_tree.set("parameters/runToggleSword/transition_request", "jog")
	animation_tree.set("parameters/walkJogSword/transition_request", "jog")
	
func run():
	#animation_tree.set("parameters/blockBlends/blend_amount", 0)
	animation_tree.set("parameters/idleMove/transition_request", "move")
	animation_tree.set("parameters/runToggle/transition_request", "run")
	
func runSword():
	#animation_tree.set("parameters/blockBlends/blend_amount", 0)
	animation_tree.set("parameters/fallMoveSword/transition_request", "move")
	animation_tree.set("parameters/idleMoveSword/transition_request", "move")
	animation_tree.set("parameters/runToggleSword/transition_request", "run")
	
func dodge():
	dodgeVec = player.input_dir
	var dodgeDir = Vector2(dodgeVec.x, -dodgeVec.y)
	var unlocked = Vector2(0, 1)
	if cam_root.lockOn == true:
		animation_tree.set("parameters/dodgeBlend/blend_position", dodgeDir)
	else:
		animation_tree.set("parameters/dodgeBlend/blend_position", unlocked)
	animation_tree.set("parameters/dodge/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func dodgeSword():
	#animation_tree.set("parameters/blockBlends/blend_amount", 0)
	animation_tree.set("parameters/fallMoveSword/transition_request", "move")
	dodgeVec = player.input_dir
	var dodgeDir = Vector2(dodgeVec.x, -dodgeVec.y)
	var unlocked = Vector2(0, 1)
	var backStep = Vector2(0, -1)
	if cam_root.lockOn == true:
		if player.direction == Vector3.ZERO:
			animation_tree.set("parameters/dodgeBlendSw/blend_position", backStep)
		else:
			animation_tree.set("parameters/dodgeBlendSw/blend_position", dodgeDir)
	else:
		if player.direction == Vector3.ZERO:
			animation_tree.set("parameters/dodgeBlendSw/blend_position", backStep)
		else:
			animation_tree.set("parameters/dodgeBlendSw/blend_position", unlocked)
	animation_tree.set("parameters/dodgeSw/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func unarm():
	animation_tree.set("parameters/manModes/transition_request", "unarm")
	#sword.queue_free()
	#sword.get_child(0).mes
	#load and unload weapon or maybe find diff way
	
func sword():
	animation_tree.set("parameters/manModes/transition_request", "sword")
	#swordObj.position = Vector3(-0.475, 0.227, 0.476)
	#swordObj.rotation = Vector3(-30.1, -34.8, -16.9)
	
func swordSwing1():
	animation_tree.set("parameters/SwordSwingChange/transition_request", "swing1")
	animation_tree.set("parameters/swordAtt/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func swordSwing2():
	animation_tree.set("parameters/SwordSwingChange/transition_request", "swing2")
	animation_tree.set("parameters/swordAtt/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func swordSwing3():
	animation_tree.set("parameters/SwordSwingChange/transition_request", "swing3")
	animation_tree.set("parameters/swordAtt/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func swordSwing4():
	animation_tree.set("parameters/SwordSwingChange/transition_request", "swing4")
	animation_tree.set("parameters/swordAtt/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func SwordSprintSwing():
	animation_tree.set("parameters/SwordSwingChange/transition_request", "sprintSwing")
	animation_tree.set("parameters/swordAtt/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func fallSwordSwing():
	animation_tree.set("parameters/fallMoveSword/transition_request", "fall")
	animation_tree.set("parameters/fallAtk/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	animation_tree
	
func swordBlockStart():
	blendVal = lerpf(blendVal, 1, 0.2)
	animation_tree.set("parameters/blockBlends/blend_amount", blendVal)
	
func swordBlockHit():
	animation_tree.set("parameters/blockBlends/blend_amount", 1.0)
	animation_tree.set("parameters/blockHitEndSW/transition_request", "hit")
	animation_tree.set("parameters/blockStartEnd/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func swordBlockEnd():
	blendVal = lerpf(blendVal, 0, 0.5)
	animation_tree.set("parameters/blockBlends/blend_amount", blendVal)
	#animation_tree.set("parameters/blockHitEndSW/transition_request", "end")
	#animation_tree.set("parameters/blockStartEnd/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func fallSwordLand():
	#animation_tree.set("parameters/fallMoveSword/transition_request", "fall")
	animation_tree.set("parameters/fallLand/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	
func swordRunSpeed(num:float):
	animation_tree.set("parameters/runSwScale/scale", num)
	
func swordJogSpeed(num:float):
	animation_tree.set("parameters/jogSwScale/scale", num)
	
func swordSwingSpd(num:float):
	animation_tree.set("parameters/swordSwingSpd/scale", num)
	
func swordDodgeSpd(num:float):
	animation_tree.set("parameters/dodgeSwScale/scale", num)
	
func hit1Sword():
	animation_tree.set("parameters/hitTrans/transition_request", "hit1")
	animation_tree.set("parameters/hitSword/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func hit2Sword():
	animation_tree.set("parameters/hitTrans/transition_request", "hit2")
	animation_tree.set("parameters/hitSword/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func hit3Sword():
	animation_tree.set("parameters/hitTrans/transition_request", "hit3")
	animation_tree.set("parameters/hitSword/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func hit4Sword():
	animation_tree.set("parameters/hitTrans/transition_request", "hit4")
	animation_tree.set("parameters/hitSword/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func hit5Sword():
	animation_tree.set("parameters/hitTrans/transition_request", "hit5")
	animation_tree.set("parameters/hitSword/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func floorStuck():
	animation_tree.set("parameters/floorStuck/transition_request", "floor")
	
func floorUnstuck():
	animation_tree.set("parameters/floorStuck/transition_request", "norm")
	
func parry1():
	animation_tree.set("parameters/blockBlends/blend_amount", 1.0)
	animation_tree.set("parameters/blockHitEndSW/transition_request", "parry1")
	animation_tree.set("parameters/blockStartEnd/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func parry2():
	animation_tree.set("parameters/blockBlends/blend_amount", 1.0)
	animation_tree.set("parameters/blockHitEndSW/transition_request", "parry2")
	animation_tree.set("parameters/blockStartEnd/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func stagger():
	animation_tree.set("parameters/staggerTrans/transition_request", "stagger")
	
func unStagger():
	animation_tree.set("parameters/staggerTrans/transition_request", "norm")
	
func abortOneShot():
	animation_tree.set("parameters/blockStartEnd/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	animation_tree.set("parameters/hitSword/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	animation_tree.set("parameters/swordAtt/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	animation_tree.set("parameters/jumpSword/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	animation_tree.set("parameters/dodgeSw/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	animation_tree.set("parameters/fallAtk/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	animation_tree.set("parameters/fallLand/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	
func cancelSword():
	animation_tree.set("parameters/swordAtt/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	
func sparksActi(pos : int = 1):
	sparks.restart()
	sparks.global_position = sp1.global_position
	sparks.emitting = true
	
	
func lineActi(pos : int = 1):
	line.restart()
	line.global_position = sp1.global_position
	line.emitting = true
