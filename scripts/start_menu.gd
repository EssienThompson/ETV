extends Node3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var continueBut: Button = $CanvasLayer/Control/MarginContainer/VBoxContainer/continue
@onready var start: Button = $CanvasLayer/Control/MarginContainer/VBoxContainer/start
@onready var options: Button = $CanvasLayer/Control/MarginContainer/VBoxContainer/options
@onready var quit: Button = $CanvasLayer/Control/MarginContainer/VBoxContainer/quit
@onready var options_menu: TextureRect = $CanvasLayer/Control/optionsMenu


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_continue_pressed() -> void:
	pass # Replace with function body.


func _on_start_pressed() -> void:
	pass # Replace with function body.


func _on_options_pressed() -> void:
	animation_player.play("options")
	toggleMMButtons(true)
	options_menu.toggleAllButtons(false)


func _on_quit_pressed() -> void:
	get_tree().quit()
	

	
	
func toggleMMButtons(opt:bool) -> void:
	continueBut.disabled = opt
	quit.disabled = opt
	start.disabled = opt
	options.disabled = opt
	


func _on_close_pressed() -> void:
	animation_player.play("optionsOut")
	toggleMMButtons(false)
	options_menu.toggleAllButtons(true)
