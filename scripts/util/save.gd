extends Node
#global name = saveManager

#var savePath: String = "user://save/notTheRun.tscn"
var settingPath : String = "user://save/definetlyTheSettings.tres"
var saveFolder : String = "user://save/"
var midrun_save_array : Dictionary 
var MIDRUN_SAVE_FILE = "user://save/notTheRun.save" 
var saveVariable : String = "user://save/mentalMaths.res"

func _ready() -> void:
	if !DirAccess.dir_exists_absolute(saveFolder):
		DirAccess.make_dir_absolute(saveFolder)
		

#func save_current_scene():
	#var current_scene = get_tree().current_scene
	#var packed_scene = PackedScene.new()
	#packed_scene.pack(current_scene)
	#ResourceSaver.save(packed_scene, savePath)
	#print("Scene saved to:", savePath)
	#
#func load_saved_scene():
	#if not FileAccess.file_exists(savePath):
		#print("Save file not found")
		#return
#
	#var loaded_scene = ResourceLoader.load(savePath)
	#if loaded_scene:
		#Events.switchToRun.emit(loaded_scene)
		#print("Scene loaded from:", savePath)
	#else:
		#print("Failed to load scene from file")

func saveSettings(setting:SettingData):
	if DirAccess.dir_exists_absolute(saveFolder):
		ResourceSaver.save(setting, settingPath)
		#print(setting.resolution," save")
	else:
		DirAccess.make_dir_absolute(saveFolder)
		ResourceSaver.save(setting, settingPath)
	
func loadSettings():
	var setting = ResourceLoader.load(settingPath)
	#print(setting.resolution, " load")
	if setting:
		return setting
	else:
		return SettingData.new()
		
func saveVari(variable:saveVariables):
	ResourceSaver.save(variable, saveVariable)
	
func loadVari():
	var vari = ResourceLoader.load(saveVariable)
	if vari:
		return vari
	
		
################################################################################################################


func mid_run_save(): 
	midrun_save_array.clear() 
	var root_level = get_node("/root/Game") 
	var map_node = get_node("/root/Game/run")
	var save_object_nodes = get_tree().get_nodes_in_group("persist") 
	#var save_ui_nodes = get_tree().get_nodes_in_group("PersistUI")
	for save_node in save_object_nodes:
		if save_node.is_inside_tree() == false:
			save_node.queue_free()
		else:
		#I'm setting "map_node" as the owner of all of these nodes I want to persist, because this is the top of the tree that I'm going to be converting into my packed scene
			 
			if save_node != map_node:
				save_node.owner = map_node

					#Now we're going to iterate through all the nodes I've said need to persist, and check if any of them have scripts attached. If they do, then we want to copy the variables inside of that script - not just the exported ones - into a dictionary we can save and load later
#
			var node_script: GDScript = save_node.get_script()
			if node_script != null:
				var node_variables = node_script.get_script_property_list()
				var save_name = "path_" + str(save_node.get_path())#change to saveID
				midrun_save_array[save_name] = {}
			
			#I've used the node path as a way to generate unique keys for the dictionary I'm storing all this data in, and a way to know how to get it back out of the dictionary when we load it all
			
				for variable in node_variables:
					var variable_name = str(variable.name)
				
									#We're going to tell it not to save any variables that are nodes themselves - this avoids recursion within the dictionary, which breaks the var2str method we're going to use, and also allows the nodes to correctly set up their various onready var references to other nodes when they're reinstantiated upon load
									#I don't have any so this is not an issue for me, keeping it anyway
					if save_node.get(variable_name) is Node or Resource:
						pass
					else:
						#print(var_to_str(save_node.get(variable_name)))
						midrun_save_array[save_name][variable_name] = var_to_str(save_node.get(variable_name)) 
#Okay, now we've got our big chunky dictionary containing both the global variables and the (non-node) variables of every single node we intend to pack up that has a script attached to it, we're going to save it to a file
	var file = FileAccess.open(MIDRUN_SAVE_FILE, FileAccess.WRITE)
	file.store_var(midrun_save_array)
	file.close()
#Next is just to pack up the node at the top of it all that will retain things for us like position, visibility, etc, of our nodes, and save that as well, creating a snapshot of our scene
	var packed_scene = PackedScene.new()
	packed_scene.pack(map_node)
	ResourceSaver.save(packed_scene, "res://scenes/saved_run.tscn") #They flipped these in Godot 4??
	
func load_saved_run():
#The first part of the loading is pretty standard, we open up our save file as long as there's one to open, and we update the global game data script's global variables with what we saved previously
	if not FileAccess.file_exists(MIDRUN_SAVE_FILE):
		return
	var save_game = FileAccess.open(MIDRUN_SAVE_FILE, FileAccess.READ)
	midrun_save_array = save_game.get_var()
#removed the global data as I do not have that

# Now we load the PackedScene resource, creating, if you will, the skeleton of the scene we created a snapshot of, and laying it out on our scene tree first

	var packed_scene = load("res://scenes/saved_run.tscn")
# Instance the scene
	var loaded_scene = packed_scene.instantiate() 
	var game = get_node("/root/Game")
	if game.get_child_count() > 0:
		game.get_child(0).queue_free()
	game.add_child(loaded_scene)
#And now that we've got the skeleton, we're going to flesh it all out with those many custom variables we wanted to stay the same. We're going to open up their various scripts, referencing their dictionary entries by using their node path to determine what the key is in the dictionary.
	var save_object_nodes = get_tree().get_nodes_in_group("persist")

	for save_node in save_object_nodes:

		var node_script: GDScript = save_node.get_script()
		var node_name = "path_" + str(save_node.get_path())
		if node_script != null and midrun_save_array.has(node_name):
			var node_data = midrun_save_array[node_name]
			for variable in node_data.keys():
				save_node.set(variable, str_to_var(node_data[variable]))
				
	loaded_scene.playerSpawn = true
	loaded_scene.setCurrScene()
	loaded_scene.loadRun()
#And we're done loading the script! If anything loads wonky, make sure you added all the nodes you wanted to the group "Persist", or whatever label you're using, and check that none of your re-instanced nodes are doing something in their ready function that you don't want them to do if they're just being loaded from a save file
	
