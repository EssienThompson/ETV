extends VBoxContainer
@export var player : Node3D
const RELIC_BUTTON = preload("res://scenes/menu&ui/relicButton.tscn")
var buttons := []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.relicAdded.connect(relicAdded)
	Events.loadRelics.connect(loadCurrRelic)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func relicAdded():
	var relic = player.relicPopup[player.relicPopup.size()-1]
	var hol = RELIC_BUTTON.instantiate()
	add_child(hol)
	hol.chngLabel(relic.relicName)
	hol.id = relic.id
	
func loadCurrRelic():
	for rel in player.relicPopup:
		var hol = RELIC_BUTTON.instantiate()
		add_child(hol)
		hol.chngLabel(rel.relicName)
		hol.id = rel.id
		
	
	#for relic in player.relicPopup:
		#var make := true
		#for butto in buttons:
			#if butto.id == relic.id:
				#make = false
		#if make:
			#var hol = RELIC_BUTTON.instantiate()
			#add_child(hol)
			#hol.chngLabel(relic.relicName)
			#hol.id = relic.id
