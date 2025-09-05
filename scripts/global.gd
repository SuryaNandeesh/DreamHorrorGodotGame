extends Node

# Global GameManager reference
var game_manager: Node = null

# Scene management
var previous_scene: String = ""
var current_scene: String = ""

func _ready():
	# This script will be added to the scene tree to provide global access
	pass

func set_game_manager(manager: Node):
	game_manager = manager

func get_game_manager() -> Node:
	return game_manager

func store_current_scene(scene_path: String):
	previous_scene = current_scene
	current_scene = scene_path

func get_previous_scene() -> String:
	return previous_scene if previous_scene != "" else "res://scenes/main_menu.tscn"
