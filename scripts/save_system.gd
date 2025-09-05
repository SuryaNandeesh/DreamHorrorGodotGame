extends Node

# Save system for managing game state persistence
# This is an autoload singleton, do not use class_name

# Save file path (base)
const SAVE_FILE_BASE = "user://savegame"
const SAVE_FILE_EXT = ".save"
const MAX_SLOTS := 5

# Save data structure
var save_data: Dictionary = {
	"player_stats": {},
	"story_progress": {},
	"character_relationships": {},
	"character_sanity": {},
	"game_flags": {},
	"save_date": "",
	"play_time": 0.0
}

# Game flags for story progression
var game_flags: Dictionary = {
	"met_daughter": false,
	"met_brother": false,
	"met_mother": false,
	"met_father": false,
	"met_shopkeeper": false,
	"completed_tutorial": false,
	"first_combat_won": false,
	"unlocked_secret_ending": false
}

func _ready():
	# Initialize default save data
	_initialize_default_save_data()

func _initialize_default_save_data():
	# Default player stats
	save_data["player_stats"] = {
		"health": 100,
		"max_health": 100,
		"attack": 20,
		"defense": 15,
		"speed": 15,
		"level": 1,
		"experience": 0,
		"experience_to_next": 100
	}
	
	# Default story progress
	save_data["story_progress"] = {
		"current_chapter": "intro",
		"completed_chapters": [],
		"current_character": "",
		"story_node": "intro"
	}
	
	# Default character relationships
	save_data["character_relationships"] = {
		"daughter": 50,
		"brother": 50,
		"mother": 50,
		"father": 50,
		"shopkeeper": 50
	}
	
	# Default character sanity
	save_data["character_sanity"] = {
		"daughter": 50,
		"brother": 50,
		"mother": 50,
		"father": 50,
		"shopkeeper": 50
	}
	
	# Default game flags
	save_data["game_flags"] = game_flags.duplicate()
	
	# Initialize save date and play time
	save_data["save_date"] = Time.get_datetime_string_from_system()
	save_data["play_time"] = 0.0

func _slot_path(slot: int = 1) -> String:
	slot = clamp(slot, 1, MAX_SLOTS)
	return SAVE_FILE_BASE + "_" + str(slot) + SAVE_FILE_EXT

func save_game(slot: int = 1):
	# Update save data with current game state
	_update_save_data()
	var path = _slot_path(slot)
	var save_file = FileAccess.open(path, FileAccess.WRITE)
	if save_file:
		var json_string = JSON.stringify(save_data)
		save_file.store_string(json_string)
		save_file.close()
		print("Game saved successfully to slot ", slot, "!")
		return true
	else:
		print("Failed to save game to slot ", slot, "!")
		return false

func load_game(slot: int = 1):
	var path = _slot_path(slot)
	if not FileAccess.file_exists(path):
		print("No save file found for slot ", slot, "!")
		return false
	var save_file = FileAccess.open(path, FileAccess.READ)
	if save_file:
		var json_string = save_file.get_as_text()
		save_file.close()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			save_data = json.data
			print("Game loaded successfully from slot ", slot, "!")
			return true
		else:
			print("Failed to parse save file for slot ", slot, "!")
			return false
	else:
		print("Failed to open save file for slot ", slot, "!")
		return false

func has_save_file(slot: int = 1) -> bool:
	return FileAccess.file_exists(_slot_path(slot))

func get_save_info(slot: int = 1) -> Dictionary:
	if has_save_file(slot):
		var save_file = FileAccess.open(_slot_path(slot), FileAccess.READ)
		if save_file:
			var json_string = save_file.get_as_text()
			save_file.close()
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				var data = json.data
				return {
					"exists": true,
					"save_date": data.get("save_date", "Unknown"),
					"play_time": data.get("play_time", 0.0),
					"player_level": data.get("player_stats", {}).get("level", 1),
					"current_chapter": data.get("story_progress", {}).get("current_chapter", "intro")
				}
	return {"exists": false}

func delete_save(slot: int = 1):
	if has_save_file(slot):
		var dir = DirAccess.open("user://")
		if dir:
			var file_name = "savegame_" + str(slot) + ".save"
			dir.remove(file_name)
			print("Save file deleted for slot ", slot, "!")
			_initialize_default_save_data()
			return true
		else:
			print("Failed to delete save file for slot ", slot, "!")
			return false
	return false

func _update_save_data():
	# Update save date
	save_data["save_date"] = Time.get_datetime_string_from_system()
	# Update play time could be handled elsewhere periodically
	# save_data["play_time"] += delta_time

func update_player_stats(stats: Dictionary):
	save_data["player_stats"] = stats.duplicate()

func update_story_progress(progress: Dictionary):
	save_data["story_progress"] = progress.duplicate()

func update_character_relationships(relationships: Dictionary):
	save_data["character_relationships"] = relationships.duplicate()

func update_character_sanity(sanity: Dictionary):
	save_data["character_sanity"] = sanity.duplicate()

func update_game_flags(flags: Dictionary):
	save_data["game_flags"] = flags.duplicate()

func set_game_flag(flag_name: String, value: bool):
	save_data["game_flags"][flag_name] = value

func get_game_flag(flag_name: String) -> bool:
	return save_data["game_flags"].get(flag_name, false)

func get_player_stats() -> Dictionary:
	return save_data["player_stats"].duplicate()

func get_story_progress() -> Dictionary:
	return save_data["story_progress"].duplicate()

func get_character_relationships() -> Dictionary:
	return save_data["character_relationships"].duplicate()

func get_character_sanity() -> Dictionary:
	return save_data["character_sanity"].duplicate()

func get_save_date() -> String:
	return save_data.get("save_date", "Unknown")

func get_play_time() -> float:
	return save_data.get("play_time", 0.0)

func export_save_data() -> Dictionary:
	return save_data.duplicate()

func import_save_data(data: Dictionary):
	save_data = data.duplicate()
	print("Save data imported successfully!")

# Auto-save functionality
var auto_save_timer: float = 0.0
var auto_save_interval: float = 300.0  # Auto-save every 5 minutes

func _process(delta):
	auto_save_timer += delta
	if auto_save_timer >= auto_save_interval:
		auto_save_timer = 0.0
		# Optionally trigger auto-save to a default slot
		# save_game(1)

# Quick save/load for testing
func quick_save(slot: int = 1):
	print("Quick save... slot ", slot)
	return save_game(slot)

func quick_load(slot: int = 1):
	print("Quick load... slot ", slot)
	return load_game(slot)
