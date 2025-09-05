extends Node

# Settings system for managing game configuration
# This is an autoload singleton, do not use class_name

# Settings categories
enum SettingCategory {AUDIO, GRAPHICS, CONTROLS, GAMEPLAY, ACCESSIBILITY}

# Default settings
var default_settings: Dictionary = {
	"audio": {
		"master_volume": 1.0,
		"music_volume": 0.8,
		"sfx_volume": 0.9,
		"voice_volume": 1.0,
		"enable_music": true,
		"enable_sfx": true,
		"enable_voice": true
	},
	"graphics": {
		"fullscreen": false,
		"max_fps": 60,
		"shadow_quality": "medium", # low, medium, high
		"anti_aliasing": "fxaa",    # none, fxaa, msaa_2x, msaa_4x
		"bloom": true,
		"motion_blur": false
	},
	"controls": {
		"mouse_sensitivity": 1.0,
		"invert_y": false,
		"gamepad_enabled": true,
		"keyboard_layout": "qwerty", # qwerty, azerty, qwertz
		"auto_save": true,
		"auto_save_interval": 300.0  # 5 minutes
	},
	"gameplay": {
		"difficulty": "normal",      # easy, normal, hard, nightmare
		"tutorial_enabled": true,
		"auto_advance_text": false,
		"text_speed": 1.0,
		"combat_animations": true,
		"horror_intensity": "medium" # low, medium, high
	},
	"accessibility": {
		"high_contrast": false,
		"large_text": false,
		"colorblind_mode": "none",   # none, protanopia, deuteranopia, tritanopia
		"subtitles": true,
		"subtitle_size": "medium",   # small, medium, large
		"screen_shake": true,
		"flashing_effects": true
	}
}

# Current settings
var current_settings: Dictionary = {}

# Settings file path
const SETTINGS_FILE_PATH = "user://settings.cfg"

# Signals
signal setting_changed(category: String, setting: String, value)
signal settings_saved()
signal settings_loaded()

func _ready():
	# Load settings or use defaults
	load_settings()

func load_settings():
	# Try to load from file, otherwise use defaults
	if FileAccess.file_exists(SETTINGS_FILE_PATH):
		var config = ConfigFile.new()
		var error = config.load(SETTINGS_FILE_PATH)
		
		if error == OK:
			# Load settings from config file
			for category in default_settings.keys():
				current_settings[category] = {}
				for setting in default_settings[category].keys():
					var value = config.get_value(category, setting, default_settings[category][setting])
					current_settings[category][setting] = value
			
			print("Settings loaded from file")
			settings_loaded.emit()
		else:
			print("Failed to load settings, using defaults")
			_use_default_settings()
	else:
		print("No settings file found, using defaults")
		_use_default_settings()

func _use_default_settings():
	# Deep copy default settings
	for category in default_settings.keys():
		current_settings[category] = default_settings[category].duplicate(true)

func save_settings():
	var config = ConfigFile.new()
	
	# Save all settings to config file
	for category in current_settings.keys():
		for setting in current_settings[category].keys():
			config.set_value(category, setting, current_settings[category][setting])
	
	# Save to file
	var error = config.save(SETTINGS_FILE_PATH)
	if error == OK:
		print("Settings saved successfully")
		settings_saved.emit()
		return true
	else:
		print("Failed to save settings")
		return false

func get_setting(category: String, setting: String):
	if current_settings.has(category) and current_settings[category].has(setting):
		return current_settings[category][setting]
	return null

func set_setting(category: String, setting: String, value):
	if current_settings.has(category) and current_settings[category].has(setting):
		current_settings[category][setting] = value
		setting_changed.emit(category, setting, value)
		
		# Auto-save certain settings
		if category == "graphics" or category == "audio":
			save_settings()
		
		return true
	return false

func reset_to_defaults():
	current_settings = {}
	_use_default_settings()
	save_settings()
	print("Settings reset to defaults")

func reset_category_to_defaults(category: String):
	if default_settings.has(category):
		current_settings[category] = default_settings[category].duplicate(true)
		save_settings()
		print("Category '", category, "' reset to defaults")

func get_audio_volume(category: String) -> float:
	return get_setting("audio", category + "_volume")

func set_audio_volume(category: String, volume: float):
	set_setting("audio", category + "_volume", clamp(volume, 0.0, 1.0))

func is_audio_enabled(category: String) -> bool:
	return get_setting("audio", "enable_" + category)

func set_audio_enabled(category: String, enabled: bool):
	set_setting("audio", "enable_" + category, enabled)

func get_graphics_setting(setting: String):
	return get_setting("graphics", setting)

func set_graphics_setting(setting: String, value):
	set_setting("graphics", setting, value)

func get_control_setting(setting: String):
	return get_setting("controls", setting)

func set_control_setting(setting: String, value):
	set_setting("controls", setting, value)

func get_gameplay_setting(setting: String):
	return get_setting("gameplay", setting)

func set_gameplay_setting(setting: String, value):
	set_setting("gameplay", setting, value)

func get_accessibility_setting(setting: String):
	return get_setting("accessibility", setting)

func set_accessibility_setting(setting: String, value):
	set_setting("accessibility", setting, value)

func get_difficulty() -> String:
	return get_gameplay_setting("difficulty")

func set_difficulty(difficulty: String):
	if difficulty in ["easy", "normal", "hard", "nightmare"]:
		set_gameplay_setting("difficulty", difficulty)

func get_horror_intensity() -> String:
	return get_gameplay_setting("horror_intensity")

func set_horror_intensity(intensity: String):
	if intensity in ["low", "medium", "high"]:
		set_gameplay_setting("horror_intensity", intensity)

func is_fullscreen() -> bool:
	return get_graphics_setting("fullscreen")

func set_fullscreen(fullscreen: bool):
	set_graphics_setting("fullscreen", fullscreen)
	# Apply fullscreen setting to window
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func get_max_fps() -> int:
	return get_graphics_setting("max_fps")

func set_max_fps(fps: int):
	set_graphics_setting("max_fps", fps)
	# Apply FPS limit
	Engine.max_fps = fps

func get_all_settings() -> Dictionary:
	return current_settings.duplicate(true)

func export_settings() -> Dictionary:
	return current_settings.duplicate(true)

func import_settings(settings: Dictionary):
	current_settings = settings.duplicate(true)
	save_settings()
	print("Settings imported successfully")

# Apply all current settings
func apply_all_settings():
	# Apply graphics settings
	set_fullscreen(is_fullscreen())
	set_max_fps(get_max_fps())
	
	# Apply audio settings
	# This would be handled by the audio system
	
	# Apply control settings
	# This would be handled by the input system
	
	print("All settings applied")

# Get settings summary for display
func get_settings_summary() -> Dictionary:
	return {
		"difficulty": get_difficulty(),
		"horror_intensity": get_horror_intensity(),
		"fullscreen": is_fullscreen(),
		"master_volume": get_audio_volume("master"),
		"auto_save": get_control_setting("auto_save")
	}
