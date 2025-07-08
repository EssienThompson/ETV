extends MarginContainer
@onready var remap_text: Label = $ColorRect/remapText
@onready var awaiting: Label = $ColorRect/awaiting
@onready var yes: Button = $ColorRect/yes
@onready var no: Button = $ColorRect/no
@onready var texture_rect: TextureRect = $ColorRect/awaiting/TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Events.buttonRemapped.connect(showMsg)
	pass
	

func showMsg(input:String, ico = null):
	if input == "open":
		remap_text.text = "Currently remapping. Input a Keyboard key or a Controller button"
		awaiting.text = "Awaiting Input..."
		texture_rect.visible = false
		yes.disabled = true
		no.disabled = true
		yes.visible = false
		no.visible = false
		visible = true
		
	elif input == "dupe":
		remap_text.text = "This button is already mapped. Are you sure you want to replace it?"
		if ico != null:
			texture_rect.texture = ico
			texture_rect.visible = true
			awaiting.text = ""
		else:
			texture_rect.visible = false
		visible = true
		yes.disabled = false
		no.disabled = false
		yes.visible = true
		no.visible = true
		no.focus()
		
	else:
		yes.disabled = true
		no.disabled = true
		visible = false
		
