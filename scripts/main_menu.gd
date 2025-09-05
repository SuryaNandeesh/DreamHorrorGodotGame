extends Control

# UI References
@onready var start_button: Button = $MainButtons/StartButton
@onready var load_button: Button = $MainButtons/LoadButton
@onready var settings_button: Button = $MainButtons/SettingsButton
@onready var quit_button: Button = $MainButtons/QuitButton
@onready var save_info: Label = $SaveInfo
@onready var delete_save_button: Button = $MainButtons/DeleteSaveButton

# Systems
@onready var save_system := get_node("/root/SaveSystem")
@onready var settings_system := get_node("/root/SettingsSystem")
@onready var character_manager := get_node("/root/CharacterManager")
@onready var sanity_system := get_node("/root/SanitySystem")

func _ready():
	_connect_ui()
	_update_save_info()
	print("Main menu initialized successfully")

func _connect_ui():
	start_button.pressed.connect(_on_start)
	load_button.pressed.connect(_on_load)
	delete_save_button.pressed.connect(_on_delete_save)
	settings_button.pressed.connect(_on_settings)
	quit_button.pressed.connect(func(): get_tree().quit())

func _update_save_info():
	var any_save_exists := false
	var save_info_text := ""
	
	# Check all save slots
	for slot in range(1, save_system.MAX_SLOTS + 1):
		var save_info_data = save_system.get_save_info(slot)
		if save_info_data.exists:
			any_save_exists = true
			save_info_text += "Slot " + str(slot) + ": Level " + str(save_info_data.player_level) + " - " + save_info_data.current_chapter + "\n"
	
	# Update UI based on save existence
	if any_save_exists:
		load_button.disabled = false
		load_button.modulate = Color.WHITE
		save_info.text = save_info_text.strip_edges()
	else:
		load_button.disabled = true
		load_button.modulate = Color(0.7, 0.7, 0.7)
		save_info.text = "No save files found"
	
	# Update delete button state
	delete_save_button.disabled = not any_save_exists
	delete_save_button.modulate = Color.WHITE if any_save_exists else Color(0.7, 0.7, 0.7)
	
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
	# Show load slot selection dialog
	var dlg := AcceptDialog.new()
	dlg.title = "Choose Load Slot"
	var v := VBoxContainer.new()
	dlg.add_child(v)
	
	var any_save := false
	for slot in range(1, save_system.MAX_SLOTS + 1):
		var info: Dictionary = save_system.get_save_info(slot)
		var btn := Button.new()
		var label := "Load Slot " + str(slot)
		if info.exists:
			any_save = true
			label += " - Level " + str(info.player_level) + " - " + str(info.current_chapter) + " (" + info.save_date + ")"
			btn.pressed.connect(func():
				if save_system.load_game(slot):
					print("Loaded slot ", slot)
					get_tree().change_scene_to_file("res://scenes/game_world.tscn")
				dlg.queue_free()
			)
		else:
			label += " - Empty"
			btn.disabled = true
			btn.modulate = Color(0.7, 0.7, 0.7)
		btn.text = label
		v.add_child(btn)
	
	if not any_save:
		_show_message("No Save Found", "There's no save data to load.")
		return
	
	add_child(dlg)
	dlg.popup_centered()

func _on_settings():
	# Open settings menu
	get_tree().change_scene_to_file("res://scenes/settings_scene.tscn")

func _on_delete_save():
	# Show delete slot selection dialog
	var dlg := AcceptDialog.new()
	dlg.title = "Choose Save to Delete"
	var v := VBoxContainer.new()
	dlg.add_child(v)
	
	var any_save := false
	for slot in range(1, save_system.MAX_SLOTS + 1):
		var info: Dictionary = save_system.get_save_info(slot)
		var btn := Button.new()
		var label := "Delete Slot " + str(slot)
		if info.exists:
			any_save = true
			label += " - Level " + str(info.player_level) + " - " + str(info.current_chapter) + " (" + info.save_date + ")"
			btn.pressed.connect(func():
				var confirm := ConfirmationDialog.new()
				confirm.title = "Confirm Delete"
				confirm.dialog_text = "Are you sure you want to delete this save? This cannot be undone."
				confirm.confirmed.connect(func():
					if save_system.delete_save(slot):
						_show_message("Deleted", "Save in slot " + str(slot) + " has been deleted.")
						_update_save_info()
						dlg.queue_free()
					else:
						_show_message("Error", "Failed to delete save in slot " + str(slot) + ".")
				)
				add_child(confirm)
				confirm.popup_centered()
			)
		else:
			label += " - Empty"
			btn.disabled = true
			btn.modulate = Color(0.7, 0.7, 0.7)
		btn.text = label
		v.add_child(btn)
	
	if not any_save:
		_show_message("No Save Found", "There's no save data to delete.")
		return
	
	add_child(dlg)
	dlg.popup_centered()

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
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
					_update_save_info()
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
						get_tree().change_scene_to_file("res://scenes/game_world.tscn")
					else:
						_show_message("Error", "Quick load failed!")
				else:
					_show_message("No Save Found", "There's no save data to load.")

func _process(_delta):
	pass 
