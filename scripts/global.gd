extends Node

# Global GameManager reference
var game_manager: Node = null

func _ready():
	# This script will be added to the scene tree to provide global access
	pass

func set_game_manager(manager: Node):
	game_manager = manager

func get_game_manager() -> Node:
	return game_manager
