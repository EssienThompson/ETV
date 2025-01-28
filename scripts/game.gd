extends Node
const START_MENU = preload("res://scenes/menu&ui/StartMenu.tscn")
const RUN = preload("res://scenes/levels/run.tscn")

var inputDevice := "Keyboard"

func _ready() -> void:
	#Events.switchToRun.connect(switchToRun)
	Events.switchToMenu.connect(switchToMenu)
	Events.newRun.connect(newRun)
	Events.loadRun.connect(loadRun)
	
#func switchToRun(run):
	#if get_child_count() > 0:
		#get_child(0).queue_free()
		#
	#var continu = run.instantiate()
	#add_child(continu)
	#continu.playerSpawn = true
	#print(continu.playerSpawn)
	
func switchToMenu():
	if get_child_count() > 0:
		get_child(0).queue_free()
		
	var sm = START_MENU.instantiate()
	add_child(sm)
	
func newRun():
	if get_child_count() > 0:
		get_child(0).queue_free()
		
	var runs = RUN.instantiate()
	add_child(runs)
	runs.startRun()
	
func loadRun():
	if get_child_count() > 0:
		get_child(0).queue_free()
		
	var runs = RUN.instantiate()
	add_child(runs)
	runs.loadRun()
	
func _input(event):
	if event is InputEventKey:
		if inputDevice != "Keyboard":
			inputDevice = "Keyboard"
		Events.inputType.emit(inputDevice)
		Dialogic.VAR.player.inDevice = "key"
		
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if inputDevice != "Controller":
			inputDevice = "Controller"
		Events.inputType.emit(inputDevice)
		Dialogic.VAR.player.inDevice = "cont"
	
