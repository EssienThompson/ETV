class_name hurtbox
extends Area3D

@export var user : Node3D
var hitboxesHit := []


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("area_entered", self._on_area_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_overlap()
	for box in hitboxesHit:
		if box.active == false:
			hitboxesHit.erase(box)


func _on_area_entered(hitB: Area3D):
	if hitB == null:
		return
	elif hitB.user == user:
		return
	elif hitboxesHit.has(hitB) == false && hitB is hitbox:
		if hitB.active:
			var hitboxInfo = []
			hitboxInfo.append(hitB.team)
			hitboxInfo.append(hitB.damage)
			hitboxInfo.append(hitB.postureDamage)
			hitboxInfo.append(hitB.hurtType)
			hitboxInfo.append(hitB.userOrigin)
			if user != null:
				if user.name == "Player":
					if user.floorStuck == false:
						user.isHit(hitboxInfo)
						#hitB.activeOff()
						hitboxesHit.append(hitB)
				else:
					user.isHit(hitboxInfo)
					hitboxesHit.append(hitB)
					#hitB.activeOff()
			
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
			if user != null:
				if user.name == "Player":
					if user.floorStuck == false:
						user.isHit(hitboxInfo)
						hitboxesHit.append(area)
						#area.activeOff()
				else:
					user.isHit(hitboxInfo)
					hitboxesHit.append(area)
					#area.activeOff()
		if area is hitbox && area.user != user && user.name == "Player" && user.hitParried == true:
			area.user.posture = area.user.posture + 20
			area.user.postLower = false
			area.user.postureTimer = 0
			user.hitParried = false
			#print("parry posture hit")
		
