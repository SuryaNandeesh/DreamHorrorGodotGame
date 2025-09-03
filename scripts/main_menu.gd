extends Control

# UI References
@onready var start_button: Button = $MainButtons/StartButton
@onready var load_button: Button = $MainButtons/LoadButton
@onready var settings_button: Button = $MainButtons/SettingsButton
@onready var quit_button: Button = $MainButtons/QuitButton
@onready var save_info: Label = $SaveInfo
@onready var delete_save_button: Button = $MainButtons/DeleteSaveButton

# Systems
var save_system: SaveSystem
var settings_system: SettingsSystem
var character_manager: CharacterManager
var sanity_system: SanitySystem

func _ready():
	_initialize_systems()
	_connect_ui()
	_update_save_info()

func _initialize_systems():
	# Initialize all systems
	save_system = SaveSystem.new()
	save_system.name = "SaveSystem"
	add_child(save_system)
	
	settings_system = SettingsSystem.new()
	settings_system.name = "SettingsSystem"
	add_child(settings_system)
	
	character_manager = CharacterManager.new()
	character_manager.name = "CharacterManager"
	add_child(character_manager)
	
	sanity_system = SanitySystem.new()
	sanity_system.name = "SanitySystem"
	add_child(sanity_system)
	
	print("Main menu systems initialized successfully")

func _connect_ui():
	start_button.pressed.connect(_on_start)
	load_button.pressed.connect(_on_load)
	delete_save_button.pressed.connect(_on_delete_save)
	settings_button.pressed.connect(_on_settings)
	quit_button.pressed.connect(func(): get_tree().quit())

func _update_save_info():
	var has_save := save_system.has_save_file()
	if has_save:
		var save_info_data = save_system.get_save_info()
		if save_info_data.exists:
			load_button.disabled = false
			load_button.modulate = Color.WHITE
			save_info.text = "Save found: Level " + str(save_info_data.player_level) + " - " + save_info_data.current_chapter
		else:
			load_button.disabled = true
			load_button.modulate = Color(0.7, 0.7, 0.7)
			save_info.text = "No save file found"
	else:
		load_button.disabled = true
		load_button.modulate = Color(0.7, 0.7, 0.7)
		save_info.text = "No save file found"
	delete_save_button.disabled = not has_save
	delete_save_button.modulate = Color(1, 1, 1) if has_save else Color(0.7, 0.7, 0.7)
	
func _on_start():
	# Start game world (VN hosted inside game world)
	get_tree().change_scene_to_file("res://scenes/game_world.tscn")

func _show_message(title: String, text: String):
	var dialog := AcceptDialog.new()
	dialog.title = title
	dialog.dialog_text = text
	add_child(dialog)
	dialog.popup_centered()

func _on_load():
	# Load existing game only if available
	if not save_system.has_save_file():
		_show_message("No Save Found", "There's no save data to load.")
		return
	if save_system.load_game():
		print("Game loaded successfully!")
		# Go to game world after load
		get_tree().change_scene_to_file("res://scenes/game_world.tscn")
	else:
		_show_message("Load Failed", "The save data could not be loaded.")

func _on_settings():
	# Open settings menu
	get_tree().change_scene_to_file("res://scenes/settings_scene.tscn")

func _on_delete_save():
	if not save_system.has_save_file():
		_show_message("No Save Found", "There's no save data to delete.")
		return
	var confirm := ConfirmationDialog.new()
	confirm.title = "Delete Save?"
	confirm.dialog_text = "Are you sure you want to delete your save? This cannot be undone."
	add_child(confirm)
	confirm.confirmed.connect(func():
		if save_system.delete_save():
			_show_message("Deleted", "Your save has been deleted.")
			_update_save_info()
		else:
			_show_message("Error", "Failed to delete save.")
	)
	confirm.popup_centered()

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F5:
				# Quick save
				if save_system.save_game():
					print("Quick save successful!")
					_update_save_info()
				else:
					print("Quick save failed!")
			KEY_F9:
				# Quick load (only if available)
				if save_system.has_save_file():
					_on_load()
				else:
					_show_message("No Save Found", "There's no save data to load.")

func _process(_delta):
	pass 
