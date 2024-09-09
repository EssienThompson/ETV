extends Control
@onready var resume_button: Button = $MarginContainer/pauseMTex/MarginContainer/VBoxContainer/resumeButton
@onready var options_button: Button = $MarginContainer/pauseMTex/MarginContainer/VBoxContainer/optionsButton
@onready var quit_button: Button = $MarginContainer/pauseMTex/MarginContainer/VBoxContainer/quitButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var options_menu: TextureRect = $optionsMenu

var gamePause := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.gamePaused.connect(Callable(self, "gameIsPaused"))
	Events.gameResumed.connect(gameIsUnpaused)
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	


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
	visible = true 
	togglePMButtons(false)
	get_tree().paused = true
	
	
func gameIsUnpaused() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	visible = false
	togglePMButtons(true)
	get_tree().paused = false


func _on_resume_button_pressed() -> void:
	gameIsUnpaused()
	Events.gameResumed.emit()
	gamePause = false
	
	


func _on_options_button_pressed() -> void:
	animation_player.play("options")
	togglePMButtons(true)
	options_menu.toggleAllButtons(false)


func _on_quit_button_pressed() -> void:
	get_tree().quit() # TODO make go back to main menu while saving


func _on_close_pressed() -> void:
	animation_player.play("optionsOut")
	togglePMButtons(false)
	options_menu.toggleAllButtons(true)


func togglePMButtons(opt:bool) -> void:
	resume_button.disabled = opt
	options_button.disabled = opt
	quit_button.disabled = opt
	
