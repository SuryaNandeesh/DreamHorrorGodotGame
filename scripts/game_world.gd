extends Control

# UI References
@onready var player_health_label: Label = $GameUI/StatusBar/StatusVBox/PlayerInfo/PlayerHealth
@onready var player_level_label: Label = $GameUI/StatusBar/StatusVBox/PlayerInfo/PlayerLevel
@onready var player_sanity_label: Label = $GameUI/StatusBar/StatusVBox/PlayerInfo/PlayerSanity
@onready var save_button: Button = $GameUI/GameContent/ActionButtons/SaveButton
@onready var load_button: Button = $GameUI/GameContent/ActionButtons/LoadButton
@onready var back_to_menu_button: Button = $GameUI/GameContent/ActionButtons/BackToMenuButton
@onready var menu_overlay: Panel = $GameUI/MenuOverlay
@onready var resume_button: Button = $GameUI/MenuOverlay/MenuContent/MenuButtons/ResumeButton
@onready var settings_button: Button = $GameUI/MenuOverlay/MenuContent/MenuButtons/SettingsButton
@onready var save_game_button: Button = $GameUI/MenuOverlay/MenuContent/MenuButtons/SaveGameButton
@onready var load_game_button: Button = $GameUI/MenuOverlay/MenuContent/MenuButtons/LoadGameButton
@onready var main_menu_button: Button = $GameUI/MenuOverlay/MenuContent/MenuButtons/MainMenuButton
@onready var quit_button: Button = $GameUI/MenuOverlay/MenuContent/MenuButtons/QuitButton
@onready var game_ui_root: Control = $GameUI
@onready var status_bar: Panel = $GameUI/StatusBar

# Systems
@onready var save_system = get_node("/root/SaveSystem")
var settings_system: SettingsSystem
var character_manager: CharacterManager
var sanity_system: SanitySystem

# Game state
var is_menu_open: bool = false
var player_sanity: float = 50.0
var current_location: String = "home"
var nearby_characters: Array = []

func _ready():
	_initialize_systems()
	_connect_ui()
	_update_player_display()
	_instance_visual_novel()

func _initialize_systems():
	# Initialize all systems except SaveSystem (now autoloaded)
	settings_system = SettingsSystem.new()
	settings_system.name = "SettingsSystem"
	add_child(settings_system)
	
	character_manager = CharacterManager.new()
	character_manager.name = "CharacterManager"
	add_child(character_manager)
	
	sanity_system = SanitySystem.new()
	sanity_system.name = "SanitySystem"
	add_child(sanity_system)
	
	# Connect signals
	sanity_system.sanity_changed.connect(_on_sanity_changed)
	
	# Load player stats from save if available
	if save_system.has_save_file():
		var player_stats = save_system.get_player_stats()
		if player_stats.has("sanity"):
			player_sanity = player_stats["sanity"]
	
	# Initialize character locations
	_initialize_character_locations()
	
	print("Game world systems initialized successfully")

func _initialize_character_locations():
	# Set up initial character locations
	character_manager.update_character_location("daughter", "bedroom")
	character_manager.update_character_location("brother", "garage")
	character_manager.update_character_location("mother", "kitchen")
	character_manager.update_character_location("father", "living_room")
	character_manager.update_character_location("shopkeeper", "shop")

func _connect_ui():
	# Action buttons
	save_button.pressed.connect(func(): _show_save_slots(true))
	load_button.pressed.connect(func(): _show_save_slots(false))
	back_to_menu_button.pressed.connect(_on_back_to_main)
	
	# Menu buttons
	resume_button.pressed.connect(_toggle_menu)
	settings_button.pressed.connect(_on_settings)
	save_game_button.pressed.connect(func(): _show_save_slots(true))
	load_game_button.pressed.connect(func(): _show_save_slots(false))
	main_menu_button.pressed.connect(_on_back_to_main)
	quit_button.pressed.connect(func(): get_tree().quit())

func _update_player_display():
	# Update player status display
	if save_system.has_save_file():
		var player_stats = save_system.get_player_stats()
		player_health_label.text = "HP: " + str(player_stats.get("health", 100)) + "/" + str(player_stats.get("max_health", 100))
		player_level_label.text = "Level: " + str(player_stats.get("level", 1))
		player_sanity_label.text = "Sanity: " + str(int(player_sanity)) + "%"
	else:
		player_health_label.text = "HP: 100/100"
		player_level_label.text = "Level: 1"
		player_sanity_label.text = "Sanity: 50%"

func _update_combat_availability():
	pass

func _instance_visual_novel():
	var vn_scene: PackedScene = load("res://scenes/visual_novel.tscn")
	if vn_scene:
		var vn = vn_scene.instantiate()
		game_ui_root.add_child(vn)
		# Hide status bar while VN is active
		status_bar.visible = false

func _show_save_slots(is_save: bool):
	var dlg := AcceptDialog.new()
	dlg.title = ("Choose Save Slot") if is_save else ("Choose Load Slot")
	var v := VBoxContainer.new()
	dlg.add_child(v)
	
	# Add a label to show current game state
	var info_label := Label.new()
	info_label.text = "Current Game State:\nLevel " + str(save_system.get_player_stats().get("level", 1)) + "\n" + save_system.get_story_progress().get("current_chapter", "intro")
	v.add_child(info_label)
	v.add_child(HSeparator.new())
	
	var any_save := false
	for i in range(1, save_system.MAX_SLOTS + 1):
		var btn := Button.new()
		var info := save_system.get_save_info(i)
		var label := ("Save to Slot " + str(i)) if is_save else ("Load Slot " + str(i))
		
		if info.exists:
			any_save = true
			label += " - Lv " + str(info.player_level) + " - " + str(info.current_chapter) + " (" + info.save_date + ")"
			if not is_save:
				btn.pressed.connect(func():
					if save_system.load_game(i):
						_show_message("Success", "Game loaded successfully!")
						_update_player_display()
						dlg.queue_free()
					else:
						_show_message("Error", "Failed to load game!")
				)
		else:
			label += " - Empty"
			if not is_save:
				btn.disabled = true
				btn.modulate = Color(0.7, 0.7, 0.7)
		
		if is_save:
			btn.pressed.connect(func():
				if info.exists:
					# Show confirmation dialog for overwriting
					var confirm := ConfirmationDialog.new()
					confirm.title = "Confirm Overwrite"
					confirm.dialog_text = "Are you sure you want to overwrite this save? This cannot be undone."
					confirm.confirmed.connect(func():
						if save_system.save_game(i):
							_show_message("Success", "Game saved successfully!")
							dlg.queue_free()
						else:
							_show_message("Error", "Failed to save game!")
					)
					add_child(confirm)
					confirm.popup_centered()
				else:
					if save_system.save_game(i):
						_show_message("Success", "Game saved successfully!")
						dlg.queue_free()
					else:
						_show_message("Error", "Failed to save game!")
			)
		
		btn.text = label
		v.add_child(btn)
	
	if not is_save and not any_save:
		_show_message("No Save Found", "There's no save data to load.")
		return
	
	add_child(dlg)
	dlg.popup_centered()

func _on_settings():
	get_tree().change_scene_to_file("res://scenes/settings_scene.tscn")

func _on_back_to_main():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _toggle_menu():
	is_menu_open = !is_menu_open
	menu_overlay.visible = is_menu_open
	
	if is_menu_open:
		get_tree().paused = true
	else:
		get_tree().paused = false

func _on_sanity_changed(new_sanity: float, old_sanity: float):
	player_sanity = new_sanity
	_update_player_display()
	print("Sanity changed from ", old_sanity, " to ", new_sanity)

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_M:
				_toggle_menu()
			KEY_ESCAPE:
				if is_menu_open:
					_toggle_menu()
				else:
					_on_back_to_main()
			KEY_F5:
				# Quick save to last used slot or slot 1
				var quick_slot := 1  # Default quick save slot
				# Find the most recent save slot
				var latest_time := 0
				for slot in range(1, save_system.MAX_SLOTS + 1):
					var info := save_system.get_save_info(slot)
					if info.exists:
						var save_time = Time.get_unix_time_from_datetime_string(info.save_date)
						if save_time > latest_time:
							latest_time = save_time
							quick_slot = slot
				
				if save_system.save_game(quick_slot):
					_show_message("Quick Save", "Game saved to slot " + str(quick_slot))
				else:
					_show_message("Error", "Quick save failed!")
			
			KEY_F9:
				# Quick load most recent save
				var latest_slot := -1
				var latest_time := 0
				for slot in range(1, save_system.MAX_SLOTS + 1):
					var info := save_system.get_save_info(slot)
					if info.exists:
						var save_time = Time.get_unix_time_from_datetime_string(info.save_date)
						if save_time > latest_time:
							latest_time = save_time
							latest_slot = slot
				
				if latest_slot != -1:
					if save_system.load_game(latest_slot):
						_show_message("Quick Load", "Game loaded from slot " + str(latest_slot))
						_update_player_display()
					else:
						_show_message("Error", "Quick load failed!")
				else:
					_show_message("No Save Found", "There's no save data to load.")

func _process(_delta):
	# No combat updates
	pass 
