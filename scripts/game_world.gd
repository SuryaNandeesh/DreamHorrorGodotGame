extends Control

# UI References
@onready var player_health_label: Label = $GameUI/StatusBar/StatusVBox/PlayerInfo/PlayerHealth
@onready var player_level_label: Label = $GameUI/StatusBar/StatusVBox/PlayerInfo/PlayerLevel
@onready var player_sanity_label: Label = $GameUI/StatusBar/StatusVBox/PlayerInfo/PlayerSanity
@onready var save_button: Button = $GameUI/GameContent/ActionButtons/SaveButton
@onready var load_button: Button = $GameUI/GameContent/ActionButtons/LoadButton
@onready var back_to_menu_button: Button = $GameUI/GameContent/ActionButtons/BackToMenuButton
@onready var menu_overlay: Panel = null  # Will be created dynamically
@onready var game_ui_root: Control = $GameUI
@onready var status_bar: Panel = $GameUI/StatusBar

# Systems
@onready var save_system := get_node("/root/SaveSystem")
@onready var settings_system := get_node("/root/SettingsSystem")
@onready var character_manager := get_node("/root/CharacterManager")
@onready var sanity_system := get_node("/root/SanitySystem")

var active_dialog: AcceptDialog = null
var pending_messages: Array[Dictionary] = []

func _show_message(title: String, text: String):
	# If a dialog is already showing, queue this message
	if active_dialog != null:
		pending_messages.append({"title": title, "text": text})
		return
	
	# Create and show the dialog
	var dialog := AcceptDialog.new()
	dialog.title = title
	dialog.dialog_text = text
	dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect to handle dialog closing
	dialog.close_requested.connect(func():
		active_dialog = null
		dialog.queue_free()
		# Show next message if any
		if pending_messages.size() > 0:
			var next = pending_messages.pop_front()
			_show_message(next.title, next.text)
	)
	
	active_dialog = dialog
	add_child(dialog)
	dialog.popup_centered()

# Game state
var is_menu_open: bool = false
var player_sanity: float = 50.0
var current_location: String = "home"
var nearby_characters: Array = []

func _ready():
	# Set process mode for pause menu
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Remove any existing menu overlay from the scene
	if has_node("GameUI/MenuOverlay"):
		get_node("GameUI/MenuOverlay").queue_free()
	
	# Create our new menu
	menu_overlay = null
	_initialize_pause_menu()
	
	# Check if we're returning from settings with pause state
	var global = get_node("/root/Global")
	if global.current_scene.contains("?paused=true"):
		await get_tree().process_frame
		_toggle_menu()  # This will set up the pause state properly
	
	_connect_ui()
	_update_player_display()
	_instance_visual_novel()
	
	# Connect signals
	sanity_system.sanity_changed.connect(_on_sanity_changed)
	
	# Load player stats from save if available
	if save_system.has_save_file():
		var player_stats = save_system.get_player_stats()
		if player_stats.has("sanity"):
			player_sanity = player_stats["sanity"]
	
	# Initialize character locations
	_initialize_character_locations()
	
	print("Game world initialized successfully")

func _initialize_pause_menu():
	# Remove any existing menu overlays to prevent duplicates
	for child in $GameUI.get_children():
		if child.name == "MenuOverlay" and child != menu_overlay:
			child.queue_free()
	
	# Create pause menu if it doesn't exist
	if not menu_overlay:
		menu_overlay = Panel.new()
		menu_overlay.name = "MenuOverlay"
		$GameUI.add_child(menu_overlay)
	
	# Set up menu overlay
	menu_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	menu_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	menu_overlay.visible = false
	menu_overlay.self_modulate = Color(0.1, 0.1, 0.1, 0.9)
	
	# Make menu overlay fill the screen
	menu_overlay.size = Vector2(1152, 648)  # Standard Godot default size
	
	# Create or get pause content
	var pause_content = menu_overlay.get_node_or_null("PauseContent")
	if not pause_content:
		pause_content = VBoxContainer.new()
		pause_content.name = "PauseContent"
		menu_overlay.add_child(pause_content)
		
		# Position in bottom right area
		pause_content.position = Vector2(600, 200)  # Move it to bottom right area
		pause_content.custom_minimum_size = Vector2(200, 300)
		pause_content.size = Vector2(200, 300)
		
		# Add some spacing between elements
		pause_content.add_theme_constant_override("separation", 10)
		
		# Add title
		var title = Label.new()
		title.text = "Pause Menu"
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.custom_minimum_size = Vector2(200, 50)  # Give title some height
		title.add_theme_font_size_override("font_size", 24)  # Make title bigger
		title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER  # Center text vertically
		pause_content.add_child(title)
		
		# Create buttons container
		var buttons = VBoxContainer.new()
		buttons.name = "PauseButtons"
		buttons.custom_minimum_size = Vector2(200, 0)  # Set minimum width
		buttons.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		buttons.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		buttons.add_theme_constant_override("separation", 10)  # Space between buttons
		pause_content.add_child(buttons)
		
		# Add buttons
		var button_data = [
			{"name": "ResumeButton", "text": "Resume"},
			{"name": "SaveGameButton", "text": "Save Game"},
			{"name": "LoadGameButton", "text": "Load Game"},
			{"name": "SettingsButton", "text": "Settings"},
			{"name": "MainMenuButton", "text": "Main Menu"},
			{"name": "QuitButton", "text": "Quit Game"}
		]
		
		for data in button_data:
			var button = Button.new()
			button.name = data.name
			button.text = data.text
			button.custom_minimum_size = Vector2(200, 40)  # Make buttons wider
			button.size_flags_horizontal = Control.SIZE_FILL
			button.mouse_filter = Control.MOUSE_FILTER_STOP
			button.process_mode = Node.PROCESS_MODE_ALWAYS
			
			# Add some style to the button
			button.add_theme_constant_override("outline_size", 2)
			button.focus_mode = Control.FOCUS_ALL
			
			buttons.add_child(button)
	
	# Set up all pause menu elements
	pause_content.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_content.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Connect button signals
	var buttons = pause_content.get_node("PauseButtons")
	if buttons:
		for button in buttons.get_children():
			match button.name:
				"ResumeButton":
					button.pressed.connect(_toggle_menu)
				"SettingsButton":
					button.pressed.connect(_on_settings)
				"SaveGameButton":
					button.pressed.connect(func(): _show_save_slots(true))
				"LoadGameButton":
					button.pressed.connect(func(): _show_save_slots(false))
				"MainMenuButton":
					button.pressed.connect(_on_back_to_main)
				"QuitButton":
					button.pressed.connect(func(): get_tree().quit())
	
	# Make sure the pause menu is on top
	menu_overlay.move_to_front()

func _initialize_character_locations():
	# Set up initial character locations
	character_manager.update_character_location("daughter", "bedroom")
	character_manager.update_character_location("brother", "garage")
	character_manager.update_character_location("mother", "kitchen")
	character_manager.update_character_location("father", "living_room")
	character_manager.update_character_location("shopkeeper", "shop")

func _connect_ui():
	# Action buttons
	if save_button:
		save_button.pressed.connect(func(): _show_save_slots(true))
	if load_button:
		load_button.pressed.connect(func(): _show_save_slots(false))
	if back_to_menu_button:
		back_to_menu_button.pressed.connect(_on_back_to_main)

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
		var info: Dictionary = save_system.get_save_info(i)
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
	# Store current scene before going to settings
	var global = get_node("/root/Global")
	if is_menu_open:
		# If coming from pause menu, store that we're paused
		global.store_current_scene("res://scenes/game_world.tscn?paused=true")
	else:
		global.store_current_scene("res://scenes/game_world.tscn")
	get_tree().change_scene_to_file("res://scenes/settings_scene.tscn")

func _on_back_to_main():
	# Make sure we unpause before going to main menu
	get_tree().paused = false
	is_menu_open = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _toggle_menu():
	is_menu_open = !is_menu_open
	
	if is_menu_open:
		# Make sure we have a valid menu overlay
		if not is_instance_valid(menu_overlay) or not menu_overlay.is_inside_tree():
			_initialize_pause_menu()
		
		# Show pause menu
		menu_overlay.visible = true
		menu_overlay.show()
		menu_overlay.move_to_front()
		
		# Make sure all pause menu buttons are interactive
		var pause_content = menu_overlay.get_node_or_null("PauseContent")
		if pause_content:
			pause_content.show()
			pause_content.mouse_filter = Control.MOUSE_FILTER_STOP
			var buttons = pause_content.get_node_or_null("PauseButtons")
			if buttons:
				for button in buttons.get_children():
					if button is Button:
						button.mouse_filter = Control.MOUSE_FILTER_STOP
		
		# Pause the game
		get_tree().paused = true
	else:
		# Hide pause menu if it exists
		if is_instance_valid(menu_overlay) and menu_overlay.is_inside_tree():
			menu_overlay.visible = false
		
		# Unpause the game
		get_tree().paused = false

func _on_sanity_changed(new_sanity: float, old_sanity: float):
	player_sanity = new_sanity
	_update_player_display()
	print("Sanity changed from ", old_sanity, " to ", new_sanity)

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_M, KEY_ESCAPE:
				if is_menu_open:
					_toggle_menu()  # Close menu
				else:
					_toggle_menu()  # Open menu
				get_viewport().set_input_as_handled()
			KEY_F5:
				# Quick save to last used slot or slot 1
				var quick_slot := 1  # Default quick save slot
				# Find the most recent save slot
				var latest_time := 0
				for slot in range(1, save_system.MAX_SLOTS + 1):
					var info: Dictionary = save_system.get_save_info(slot)
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
					var info: Dictionary = save_system.get_save_info(slot)
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
