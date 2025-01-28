extends Control
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var resume_button: Button = $CanvasLayer/MarginContainer/pauseMTex/MarginContainer/VBoxContainer/resumeButton
@onready var options_button: Button = $CanvasLayer/MarginContainer/pauseMTex/MarginContainer/VBoxContainer/optionsButton
@onready var quit_button: Button = $CanvasLayer/MarginContainer/pauseMTex/MarginContainer/VBoxContainer/quitButton
@onready var options_menu: TextureRect = $CanvasLayer/optionsMenu
@onready var canvasLayer: CanvasLayer = $CanvasLayer

var gamePause := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.gamePaused.connect(Callable(self, "gameIsPaused"))
	Events.gameResumed.connect(gameIsUnpaused)
	process_mode = Node.PROCESS_MODE_ALWAYS
	canvasLayer.visible = false
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		gamePause = !gamePause
		if gamePause:
			Events.gamePaused.emit()
		else:
			Events.emit_signal("gameResumed")
	

func gameIsPaused() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	canvasLayer.visible = true 
	Dialogic.paused = true
	togglePMButtons(false)
	get_tree().paused = true
	resume_button.focus()
	
	
func gameIsUnpaused() -> void:
	_on_close_pressed()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	canvasLayer.visible = false
	Dialogic.paused = false
	togglePMButtons(true)
	get_tree().paused = false
	

func _on_resume_button_pressed() -> void:
	Events.gameResumed.emit()
	gamePause = false
	animation_player.play("RESET")
	


func _on_options_button_pressed() -> void:
	animation_player.play("options")
	togglePMButtons(true)
	Events.optionsOpened.emit()
	options_menu.toggleAllButtons(false)
	options_menu.setFocus()


func _on_quit_button_pressed() -> void:
	Events.emit_signal("gameResumed")
	#get_tree().paused = false
	Events.switchToMenu.emit()
	animation_player.play("RESET")
	#Events.emit_signal("gameExited")
	


func _on_close_pressed() -> void:
	animation_player.play("optionsOut")
	togglePMButtons(false)
	Events.optionsClosed.emit()
	options_menu.saveSetting()
	options_menu.toggleAllButtons(true)
	resume_button.focus()


func togglePMButtons(opt:bool) -> void:
	resume_button.disabled = opt
	options_button.disabled = opt
	quit_button.disabled = opt
	
