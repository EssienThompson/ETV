extends TextureRect
@onready var screen_mode_button: OptionButton = $graphicsSettings/graphicSelectors/VBoxContainer/screenModeButton
@onready var resolution_button: OptionButton = $graphicsSettings/graphicSelectors/VBoxContainer/resolutionButton
@onready var vsync_button: Button = $graphicsSettings/graphicSelectors/VBoxContainer/vsyncButton
@onready var framerate_button: OptionButton = $graphicsSettings/graphicSelectors/VBoxContainer/framerateButton
@onready var graphics: Button = $HBoxContainer/graphics
@onready var controls: Button = $HBoxContainer/controls
@onready var close: Button = $close
@onready var graphics_settings: Control = $graphicsSettings
@onready var controls_settings: Control = $controlsSettings


var vsync := true
var timer := 0.0
var focus := false
var setting := SettingData.new()
#var currPage := "graphics"

var resolutions := [Vector2i(1280,720),
Vector2i(1366,768),
Vector2i(1600,900),
Vector2i(1920,1080),
Vector2i(2560,1440),
Vector2i(3840,2160)]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	loadSetting()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timer <= 0.6 and focus:
		timer += delta
		setFocus()
		
	if timer > 0.6:
		focus = false

func _on_resolution_button_item_selected(index: int) -> void:
	match index:
		0:
			get_window().set_size(Vector2i(1280, 720))
		1:
			get_window().set_size(Vector2i(1366, 768))
		2:
			get_window().set_size(Vector2i(1600, 900))
		3:
			get_window().set_size(Vector2i(1920, 1080))
		4:
			get_window().set_size(Vector2i(2560, 1440))
		5: 
			get_window().set_size(Vector2i(3840, 2160)) 
			
	centreWindow()
	if get_window().get_mode() == Window.MODE_EXCLUSIVE_FULLSCREEN:
		screen_mode_button.select(1)
		screen_mode_button.emit_signal("item_selected", 1)
	setting.resolution = index


func _on_screen_mode_button_item_selected(index: int) -> void:
	match index:
		0:
			get_window().set_mode(Window.MODE_EXCLUSIVE_FULLSCREEN)
			get_window().borderless = false
			setCurrRes()#resolution_button.select(6)
		1:
			get_window().set_mode(Window.MODE_WINDOWED)
			get_window().borderless = false
			setCurrRes()
		2:
			get_window().set_mode(Window.MODE_WINDOWED)
			get_window().borderless = true
			setCurrRes()
			
	setting.screenMode = index
			
func centreWindow():
	var centreScreen = DisplayServer.screen_get_position()+DisplayServer.screen_get_size()/2
	var windSize = get_window().get_size_with_decorations()
	get_window().set_position(centreScreen-windSize/2)


func _on_vsync_button_pressed() -> void:
	vsync = !vsync
	changeVsync()

func changeVsync():
	if vsync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		vsync_button.text = "On"
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		vsync_button.text = "Off"
	setting.vsync = vsync


func _on_framerate_button_item_selected(index: int) -> void:
	match index:
		0:
			Engine.max_fps = 30
		1:
			Engine.max_fps = 60
		2:
			Engine.max_fps = 90
		3:
			Engine.max_fps = 120
		4:
			Engine.max_fps = 144
		5:
			Engine.max_fps = 165
		6:
			Engine.max_fps = 240
		7:
			Engine.max_fps = 0
	setting.fpsCap = index
			
			
func setCurrRes() -> void:
	var currRes = get_window().get_size()
	var count = 0
	for res in resolutions:
		if currRes == res:
			resolution_button.select(count)
			setting.resolution = count
		count += 1
	
func toggleAllButtons(opt:bool) -> void:
	close.disabled = opt
	graphics.disabled = opt
	controls.disabled = opt
	if opt == false:
		focus = true
		timer = 0
		
func setFocus():
	graphics.focus()
	_on_graphics_pressed()
	
func loadSetting():
	var sets = saveManager.loadSettings()
	#print(sets," load")
	screen_mode_button.select(sets.screenMode) 
	_on_screen_mode_button_item_selected(sets.screenMode)
	resolution_button.select(sets.resolution)
	_on_resolution_button_item_selected(sets.resolution)
	framerate_button.select(sets.fpsCap)
	_on_framerate_button_item_selected(sets.fpsCap)
	vsync = sets.vsync
	changeVsync()
	controls_settings.call_deferred("loadRemap", sets.remap)
	
func saveSetting():
	#print(setting," save")
	setting.remap = controls_settings.remapDict
	saveManager.saveSettings(setting)
	
func closeAllPages():
	graphics_settings.closePage(true)
	controls_settings.closePage(true)

func _on_graphics_pressed() -> void:
	graphics_settings.closePage(false)
	controls_settings.closePage(true)
	# close other pages added
	

func _on_controls_pressed() -> void:
	graphics_settings.closePage(true)
	controls_settings.closePage(false)
