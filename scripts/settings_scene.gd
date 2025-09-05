extends Control

# UI References
@onready var master_volume_slider: HSlider = $SettingsUI/SettingsContainer/SettingsVBox/AudioSection/MasterVolume/MasterVolumeSlider
@onready var master_volume_value: Label = $SettingsUI/SettingsContainer/SettingsVBox/AudioSection/MasterVolume/MasterVolumeValue
@onready var music_volume_slider: HSlider = $SettingsUI/SettingsContainer/SettingsVBox/AudioSection/MusicVolume/MusicVolumeSlider
@onready var music_volume_value: Label = $SettingsUI/SettingsContainer/SettingsVBox/AudioSection/MusicVolume/MusicVolumeValue
@onready var sfx_volume_slider: HSlider = $SettingsUI/SettingsContainer/SettingsVBox/AudioSection/SFXVolume/SFXVolumeSlider
@onready var sfx_volume_value: Label = $SettingsUI/SettingsContainer/SettingsVBox/AudioSection/SFXVolume/SFXVolumeValue

@onready var fullscreen_checkbox: CheckBox = $SettingsUI/SettingsContainer/SettingsVBox/GraphicsSection/Fullscreen/FullscreenCheckBox

@onready var reset_defaults_button: Button = $SettingsUI/SettingsContainer/SettingsVBox/ButtonSection/ResetDefaultsButton
@onready var save_button: Button = $SettingsUI/SettingsContainer/SettingsVBox/ButtonSection/SaveButton
@onready var back_button: Button = $SettingsUI/SettingsContainer/SettingsVBox/ButtonSection/BackButton

# Settings system
@onready var settings_system := get_node("/root/SettingsSystem")

func _ready():
	# Make sure settings UI can be interacted with
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Make sure the settings UI root is interactive
	var settings_ui = get_node("SettingsUI")
	settings_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	settings_ui.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Make the container interactive
	var settings_container = settings_ui.get_node("SettingsContainer")
	settings_container.process_mode = Node.PROCESS_MODE_ALWAYS
	settings_container.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Make all UI elements interactive
	for child in get_node("SettingsUI/SettingsContainer/SettingsVBox").get_children():
		child.process_mode = Node.PROCESS_MODE_ALWAYS
		child.mouse_filter = Control.MOUSE_FILTER_STOP
		# Make all children of sections interactive too
		for grandchild in child.get_children():
			grandchild.process_mode = Node.PROCESS_MODE_ALWAYS
			grandchild.mouse_filter = Control.MOUSE_FILTER_STOP
			# Make all controls in containers interactive
			if grandchild is Container:
				for control in grandchild.get_children():
					control.process_mode = Node.PROCESS_MODE_ALWAYS
					control.mouse_filter = Control.MOUSE_FILTER_STOP
	
	_setup_ui()
	_connect_ui()
	_load_current_settings()

func _setup_ui():
	# Set up audio sliders
	master_volume_slider.mouse_filter = Control.MOUSE_FILTER_STOP
	master_volume_slider.step = 0.01
	master_volume_slider.min_value = 0.0
	master_volume_slider.max_value = 1.0
	
	music_volume_slider.mouse_filter = Control.MOUSE_FILTER_STOP
	music_volume_slider.step = 0.01
	music_volume_slider.min_value = 0.0
	music_volume_slider.max_value = 1.0
	
	sfx_volume_slider.mouse_filter = Control.MOUSE_FILTER_STOP
	sfx_volume_slider.step = 0.01
	sfx_volume_slider.min_value = 0.0
	sfx_volume_slider.max_value = 1.0
	
	# Set up fullscreen checkbox
	fullscreen_checkbox.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Set up buttons
	reset_defaults_button.mouse_filter = Control.MOUSE_FILTER_STOP
	save_button.mouse_filter = Control.MOUSE_FILTER_STOP
	back_button.mouse_filter = Control.MOUSE_FILTER_STOP

func _connect_ui():
	# Audio sliders
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	
	# Graphics checkboxes
	fullscreen_checkbox.toggled.connect(_on_fullscreen_toggled)
	
	# Buttons
	reset_defaults_button.pressed.connect(_on_reset_defaults)
	save_button.pressed.connect(_on_save_settings)
	back_button.pressed.connect(_on_back_to_main)

func _load_current_settings():
	# Load audio settings
	var master_vol = settings_system.get_audio_volume("master")
	master_volume_slider.value = master_vol
	master_volume_value.text = str(int(master_vol * 100)) + "%"
	
	var music_vol = settings_system.get_audio_volume("music")
	music_volume_slider.value = music_vol
	music_volume_value.text = str(int(music_vol * 100)) + "%"
	
	var sfx_vol = settings_system.get_audio_volume("sfx")
	sfx_volume_slider.value = sfx_vol
	sfx_volume_value.text = str(int(sfx_vol * 100)) + "%"
	
	# Load graphics settings
	fullscreen_checkbox.button_pressed = settings_system.is_fullscreen()

func _on_master_volume_changed(value: float):
	settings_system.set_audio_volume("master", value)
	master_volume_value.text = str(int(value * 100)) + "%"

func _on_music_volume_changed(value: float):
	settings_system.set_audio_volume("music", value)
	music_volume_value.text = str(int(value * 100)) + "%"

func _on_sfx_volume_changed(value: float):
	settings_system.set_audio_volume("sfx", value)
	sfx_volume_value.text = str(int(value * 100)) + "%"

func _on_fullscreen_toggled(button_pressed: bool):
	settings_system.set_fullscreen(button_pressed)

func _on_reset_defaults():
	settings_system.reset_to_defaults()
	_load_current_settings()
	print("Settings reset to defaults")

func _on_save_settings():
	settings_system.save_settings()
	print("Settings saved successfully")

func _on_back_to_main():
	# Get the previous scene from Global
	var global = get_node("/root/Global")
	var previous_scene = global.get_previous_scene()
	
	# Check if we should return to a paused game
	if previous_scene.contains("?paused=true"):
		previous_scene = previous_scene.split("?")[0]  # Remove the query parameter
		# We'll set up the pause state after changing scene
		get_tree().change_scene_to_file(previous_scene)
		await get_tree().process_frame  # Wait for scene to change
		get_tree().paused = true
		# Get the game world node and show its pause menu
		var game_world = get_tree().current_scene
		if game_world and game_world.has_method("_toggle_menu"):
			game_world._toggle_menu()
	else:
		get_tree().change_scene_to_file(previous_scene)

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				_on_back_to_main()
			KEY_S:
				if event.ctrl_pressed:
					_on_save_settings()
