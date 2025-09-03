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
var settings_system: SettingsSystem

func _ready():
	_initialize_settings_system()
	_setup_ui()
	_connect_ui()
	_load_current_settings()

func _initialize_settings_system():
	settings_system = SettingsSystem.new()
	settings_system.name = "SettingsSystem"
	add_child(settings_system)

func _setup_ui():
	pass

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
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				_on_back_to_main()
			KEY_S:
				if event.ctrl_pressed:
					_on_save_settings()
