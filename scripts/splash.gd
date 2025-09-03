extends Control

@onready var fade_rect: ColorRect = $Fade

var fade_time: float = 2.5
var hold_time: float = 2.5

func _ready():
	# Start with black, fade to show the text, hold, then fade to main menu
	fade_rect.color.a = 1.0
	_show_warning_then_continue()

func _show_warning_then_continue() -> void:
	var tween = create_tween()
	# Fade in from black to reveal text
	tween.tween_property(fade_rect, "color:a", 0.0, fade_time)
	# Hold on screen
	tween.tween_interval(hold_time)
	# Fade back to black
	tween.tween_property(fade_rect, "color:a", 1.0, fade_time)
	tween.tween_callback(_go_to_menu)

func _go_to_menu():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


