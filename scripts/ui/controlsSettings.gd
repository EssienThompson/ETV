extends Control

@onready var inputButtonRemap = preload("res://scenes/menu&ui/InputButton(Remap).tscn")
@onready var actionList =  $PanelContainer/graphicsHeaders/VBoxContainer/ScrollContainer/ActionList
@onready var reset: Button = $PanelContainer/graphicsHeaders/VBoxContainer/reset
@onready var remap_msg: MarginContainer = $remapMsg

var isRemapping := false
var isConflicting := false
var actionToRemap = null
var conflictingAction = null
var remappingButton = null
var conflPos := -1
#var inType := "Keyboard"
var remapDict : Dictionary = {}

var inputActions = {
	"move_forward": "Move forward",
	"move_left": "Move left",
	"move_right": "Move right",
	"move_back": "Move back",
	"Jump": "Jump",
	"sprint": "Dodge",
	"attack": "Attack",
	"block" : "Block",
	"lock_on": "Lock on",
	"map": "Map",
	"interect": "Interact"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	createActionList()
	remap_msg.showMsg("close")
	#Events.inputType.connect(changeInputType)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
	
func createActionList():
	InputMap.load_from_project_settings()
	for item in actionList.get_children():
		item.queue_free()
		
	for action in inputActions:
		var button = inputButtonRemap.instantiate()
		var actionLabel = button.find_child("LabelAction")
		var inputLabel = button.find_child("LabelInput")
		
		actionLabel.text = inputActions[action]
		button.action = action
		
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			inputLabel.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			inputLabel.text = ""
			
		if events.size() > 1:
			updateContAction(button, events[1])
			
			
		actionList.add_child(button)
		#call_deferred("addAction", action, events)
		addAction(action, events)
		button.pressed.connect(_on_input_button_pressed.bind(button, action))
		
func _on_input_button_pressed(button, action):
	if !isRemapping && !isConflicting:
		isRemapping = true
		actionToRemap = action
		remappingButton = button
		button.find_child("LabelInput").text = "Press key to bind.."
		remap_msg.showMsg("open")
		#Events.buttonRemapped.emit("open")
	
func _input(event):
	if isRemapping:
		if event is InputEventKey or (event is InputEventMouseButton && event.pressed):
			if event is InputEventMouseButton && event.double_click:
				event.double_clicked = false
				
			conflictingAction = checkDupe(actionToRemap, event)
			if conflictingAction != "noDupe":
				remap_msg.awaiting.text = event.as_text().trim_suffix(" (Physical)")
				remap_msg.showMsg("dupe")
				isConflicting = true
				isRemapping = false
				conflPos = 0
				
				accept_event()
				
			else:
				remapKeyInput(remappingButton, event, actionToRemap)
				
				isRemapping = false
				actionToRemap = null
				conflictingAction = null
				remappingButton = null
				conflPos = -1
				remap_msg.showMsg("close")
				#Events.buttonRemapped.emit("close")
				
				accept_event()
			
			
		if event is InputEventJoypadMotion and absf(event.axis_value) >= 0.5:
			conflictingAction = checkDupe(actionToRemap, event)
			if conflictingAction != "noDupe":
				var icon = updateContAction(remappingButton, event, true)
				remap_msg.showMsg("dupe", icon)
				isConflicting = true
				isRemapping = false
				conflPos = 1
				
				accept_event()
			else:
				remapContInput(remappingButton, event, actionToRemap)
				
				isRemapping = false
				actionToRemap = null
				conflictingAction = null
				remappingButton = null
				conflPos = -1
				remap_msg.showMsg("close")
				#Events.buttonRemapped.emit("close")
				
				accept_event()
			
		if event is InputEventJoypadButton:
			conflictingAction = checkDupe(actionToRemap, event)
			if conflictingAction != "noDupe":
				var icon = updateContAction(remappingButton, event, true)
				remap_msg.showMsg("dupe", icon)
				isConflicting = true
				isRemapping = false
				conflPos = 1
				
				accept_event()
			
			else:
				remapContInput(remappingButton, event, actionToRemap)
				
				isRemapping = false
				actionToRemap = null
				conflictingAction = null
				remappingButton = null
				conflPos = -1
				remap_msg.showMsg("close")
				#Events.buttonRemapped.emit("close")
				
				accept_event()
			
			
func updateActionList(button, event):
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")
	
func updateContAction(button, event, get = false):
	if event is InputEventJoypadButton:
		var eventBut = event.button_index
		match eventBut:
			0:
				if get == true:
					return button.call_deferred("getIcon", "A")
				else:
					button.call_deferred("changeIcon", "A")
			1:
				if get == true:
					return button.call_deferred("getIcon", "B")
				else:
					button.call_deferred("changeIcon","B")
			2:
				if get == true:
					return button.call_deferred("getIcon", "X")
				else:
					button.call_deferred("changeIcon", "X")
			3:
				if get == true:
					return button.call_deferred("getIcon", "Y")
				else:
					button.call_deferred("changeIcon", "Y")
			4:
				if get == true:
					return button.call_deferred("getIcon", "H")
				else:
					button.call_deferred("changeIcon", "H")
			7:
				if get == true:
					return button.call_deferred("getIcon", "LSt")
				else:
					button.call_deferred("changeIcon", "LSt")
			8:
				if get == true:
					return button.call_deferred("getIcon", "RSt")
				else:
					button.call_deferred("changeIcon", "RSt")
			9:
				if get == true:
					return button.call_deferred("getIcon", "LBump")
				else:
					button.call_deferred("changeIcon", "LBump")
			10:
				if get == true:
					return button.call_deferred("getIcon", "RBump")
				else:
					button.call_deferred("changeIcon", "RBump")
			11:
				if get == true:
					return button.call_deferred("getIcon", "DpadU")
				else:
					button.call_deferred("changeIcon", "DpadU")
			12:
				if get == true:
					return button.call_deferred("getIcon", "DpadD")
				else:
					button.call_deferred("changeIcon", "DpadD")
			13:
				if get == true:
					return button.call_deferred("getIcon", "DpadL")
				else:
					button.call_deferred("changeIcon", "DpadL")
			14:
				if get == true:
					return button.call_deferred("getIcon", "DpadR")
				else:
					button.call_deferred("changeIcon", "DpadR")
	
	elif event is InputEventJoypadMotion:
		var eventJoy = event.axis
		var eventVal = event.axis_value
		match eventJoy:
			0:
				if eventVal > 0:
					if get == true:
						return button.call_deferred("getIcon", "LStR")
					else:
						button.call_deferred("changeIcon", "LStR")
				else:
					if get == true:
						return button.call_deferred("getIcon", "LStL")
					else:
						button.call_deferred("changeIcon", "LStL")
						
			1:
				if eventVal > 0:
					if get == true:
						return button.call_deferred("getIcon", "LStD")
					else:
						button.call_deferred("changeIcon", "LStD")
				else:
					if get == true:
						return button.call_deferred("getIcon", "LStU")
					else:
						button.call_deferred("changeIcon", "LStU")
					
			2:
				if eventVal > 0:
					if get == true:
						return button.call_deferred("getIcon", "RStR")
					else:
						button.call_deferred("changeIcon", "RStR")
				else:
					if get == true:
						return button.call_deferred("getIcon", "RStL")
					else:
						button.call_deferred("changeIcon", "RStL")
					
			3:
				if eventVal > 0:
					if get == true:
						return button.call_deferred("getIcon", "RStD")
					else:
						button.call_deferred("changeIcon", "RStD")
				else:
					if get == true:
						return button.call_deferred("getIcon", "RStU")
					else:
						button.call_deferred("changeIcon", "RStU")
					
			4:
				if get == true:
					return button.call_deferred("getIcon", "LTrigg")
				else:
					button.call_deferred("changeIcon", "LTrigg")
				
			5:
				if get == true:
					return button.call_deferred("getIcon", "RTrigg")
				else:
					button.call_deferred("changeIcon", "RTrigg")
				
			
func remapContInput(button, event, action):
	var eventsInSave = remapDict[action]
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, eventsInSave[0])
	InputMap.action_add_event(action, event)
	eventsInSave[1] = event
	
	remapDict[action] = eventsInSave
	updateContAction(remappingButton, event)
	
func remapKeyInput(button, event, action):
	var eventsInSave = remapDict[action]
	InputMap.action_erase_events(actionToRemap)
	InputMap.action_add_event(actionToRemap, event)
	InputMap.action_add_event(actionToRemap, eventsInSave[1])
	eventsInSave[0] = event
	
	remapDict[action] = eventsInSave
	updateActionList(remappingButton, event)
	
func loadRemap(saved):
	for button in actionList.get_children():
		if button.action != null:
			var action = button.action
			if saved.has(action):
				var savedEv = saved[action]
				InputMap.action_erase_events(action)
				InputMap.action_add_event(action, savedEv[0])
				InputMap.action_add_event(action, savedEv[1])
				updateActionList(button, savedEv[0])
				updateContAction(button, savedEv[1])

			else:
				if remapDict.has(action):
					saved[action] = remapDict[action]
				else:
					var holEv = InputMap.action_get_events(action)
					saved[action] = holEv
					
	remapDict = saved
	
func addAction(action, event):
	remapDict[action] = event
	
	
func checkDupe(action, event):
	for act in remapDict:
		if act != action:
			var holArr = remapDict[act]
			var holEv1 = holArr[0]
			var holEv2 = holArr[1]
			if event is InputEventJoypadButton && holEv2 is InputEventJoypadButton:
				if event.button_index == holEv2.button_index:
					return act
					
			elif event is InputEventJoypadMotion && holEv2 is InputEventJoypadMotion:
				if ((event.axis_value >= 0.5 && holEv2.axis_value >= 0.5) or (event.axis_value <= -0.5 && holEv2.axis_value <= -0.5)) && (event.axis == holEv2.axis):
					return act
					
			elif event is InputEventMouseButton && holEv1 is InputEventMouseButton:
				if event.button_index == holEv1.button_index:
					return act
					
			elif event is InputEventKey && holEv1 is InputEventKey:
				if (event.physical_keycode == holEv1.physical_keycode) or (event.keycode == holEv1.keycode) or (event.keycode == holEv1.physical_keycode):
					return act
					
	return "noDupe"

func _on_reset_pressed() -> void:
	createActionList()
	
#func changeInputType(type:String):
	#inType = type


func _on_yes_pressed() -> void:
	if isConflicting:
		var eventC = remapDict[conflictingAction]
		var eventS = remapDict[actionToRemap]
		var hol = eventC[conflPos]
		eventC[conflPos] = eventS[conflPos]
		eventS[conflPos] = hol
		remapDict[conflictingAction] = eventC
		remapDict[actionToRemap] = eventS
		
		updateActionList(remappingButton, eventS[0])
		updateContAction(remappingButton, eventS[1])
		
		var confBut
		for acti in actionList.get_children():
			if acti.action == conflictingAction:
				confBut = acti
		updateActionList(confBut, eventC[0])
		updateContAction(confBut, eventC[1])
		
		isConflicting = false
		isRemapping = false
		actionToRemap = null
		conflictingAction = null
		remappingButton = null
		remap_msg.showMsg("close")
			
		

func _on_no_pressed() -> void:
	var hol = remapDict[actionToRemap]
	var eve = hol[0]
	updateActionList(remappingButton, eve)
	
	isConflicting = false
	isRemapping = false
	actionToRemap = null
	conflictingAction = null
	remappingButton = null
	conflPos = -1
	remap_msg.showMsg("close")
	
func toggleButtons(opt:bool):
	for but in actionList.get_children():
		but.disabled = opt
	reset.disabled = opt
	
func closePage(opt:bool):
	toggleButtons(opt)
	visible = !opt
