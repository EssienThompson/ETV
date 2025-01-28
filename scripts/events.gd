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
signal buttonRemapped(input:String) #for msg not actually remapping
signal inputType(input:String)

const GREYL_POP = preload("res://scenes/relics/GreylPop.tscn")

func loadRelicPopup(player):
	for relic in player.relic:
		match relic:
			100:
				var greyl = GREYL_POP.instantiate()
				player.relicPopup.append(greyl)
				player.add_child(greyl)

var magiOpt := 0
