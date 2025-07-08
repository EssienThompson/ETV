class_name hurtbox
extends Area3D

@export var user : Node3D
var hitboxesHit := []


# Called when the node enters the scene tree for the first time.
#func _ready():
	#connect("area_entered", self._on_area_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	check_overlap()
	for box in hitboxesHit:
		if box.active == false:
			hitboxesHit.erase(box)


#func _on_area_entered(hitB: Area3D):
	#if hitB == null:
		#return
	#elif hitB.user == user:
		#return
	#elif hitboxesHit.has(hitB) == false && hitB is hitbox:
		#if hitB.active:
			#var hitboxInfo = []
			#hitboxInfo.append(hitB.team)
			#hitboxInfo.append(hitB.damage)
			#hitboxInfo.append(hitB.postureDamage)
			#hitboxInfo.append(hitB.hurtType)
			#hitboxInfo.append(hitB.userOrigin)
			#hitboxInfo.append(hitB.user)
			#if user != null:
				#if user.name == "Player":
					#if user.floorStuck == false:
						#user.isHit(hitboxInfo)
						##hitB.activeOff()
						#hitboxesHit.append(hitB)
				#else:
					#user.isHit(hitboxInfo)
					#hitboxesHit.append(hitB)
					##hitB.activeOff()
			
func check_overlap():
	var overlap = get_overlapping_areas()
	for area in overlap:
		if area is hitbox && area.active && area.user != user && hitboxesHit.has(area) == false:
			var hitboxInfo = []
			hitboxInfo.append(area.team)
			hitboxInfo.append(area.damage)
			hitboxInfo.append(area.postureDamage)
			hitboxInfo.append(area.hurtType)
			hitboxInfo.append(area.userOrigin)
			hitboxInfo.append(area.user)
			if user != null:
				if user.name == "Player":
					if user.floorStuck == false:
						user.isHit(hitboxInfo)
						hitboxesHit.append(area)
						#area.activeOff()
				else:
					if area.user.name == "Player":
						Events.hitstop(0.05, 0.05)
					user.isHit(hitboxInfo)
					hitboxesHit.append(area)
					#area.activeOff()
		#hitParried = "I parried a hit"
		#gotParried = "I got parried"
		if area is hitbox && area.user != user && "hitParried" in user && user.hitParried == true: #removed user.name == "Player"
			#area.user.posture = area.user.posture + 20
			#if "postLower" in area.user:
				#area.user.postLower = false
			#if "postureTimer" in area.user:
				#area.user.postureTimer = 0
			###This is now handled in each characters parried func
			user.hitParried = false
			#print("parry posture hit")
		
