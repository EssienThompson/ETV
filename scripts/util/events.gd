extends Node

signal battleWon
signal battleLost
signal mapExited(room:Room)
signal shopExited
signal restExited
signal treasureExited
signal gamePaused
signal gameResumed
signal hideMap
signal showMap
signal spawnEnemies
#signal gameExited
signal relicAdded
signal relicSelected(id:int)
signal optionsOpened
signal optionsClosed
signal focusChanged(room:Room)
signal focusCheck
#signal switchToRun(run)
signal switchToMenu
signal newRun
signal loadRun
signal loadRelics
#signal buttonRemapped(input:String) #for msg not actually remapping
signal inputType(input:String)
signal militiaAlert(alertPosition:Vector3)

var magiOpt := 0
var militiaSuspects := []

const GREYL_POP = preload("res://scenes/relics/GreylPop.tscn")

func loadRelicPopup(player):
	for relic in player.relic:
		match relic:
			100:
				var greyl = GREYL_POP.instantiate()
				player.relicPopup.append(greyl)
				player.add_child(greyl)

func hitstop(timescale: float = 0.05, duration: float = 0.1):
	Engine.time_scale = timescale  # Slow down time briefly
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0
