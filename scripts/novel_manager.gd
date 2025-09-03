extends Control

@onready var background_rect: TextureRect = $Background
@onready var dialogue_panel: Panel = $DialoguePanel
@onready var speaker_label: Label = $DialoguePanel/Speaker
@onready var dialogue_label: Label = $DialoguePanel/Text
@onready var choices_container: VBoxContainer = $Choices
@onready var red_overlay: ColorRect = $RedOverlay
@onready var start_screen: Control = $StartScreen
@onready var save_screen: Control = $SaveScreen
@onready var game_over_screen: Control = $GameOverScreen
@onready var start_button: Button = $StartScreen/StartContainer/StartButton
@onready var quit_button: Button = $StartScreen/StartContainer/QuitButton
@onready var save_back_button: Button = $SaveScreen/SavePanel/SaveVBox/SaveBackButton
@onready var go_restart_button: Button = $GameOverScreen/GameOverPanel/GameOverVBox/GameOverButtons/GameOverRestartButton
@onready var go_quit_button: Button = $GameOverScreen/GameOverPanel/GameOverVBox/GameOverButtons/GameOverQuitButton
@onready var test_menu_button: Button = $StartScreen/StartContainer/TestMenuButton
@onready var character_image: TextureRect = $DialoguePanel/CharacterImage
@onready var vn_text: RichTextLabel = $VNText
@onready var pause_overlay: Panel = $PauseOverlay
@onready var pause_resume_button: Button = $PauseOverlay/PauseContent/PauseButtons/ResumeButton
@onready var pause_settings_button: Button = $PauseOverlay/PauseContent/PauseButtons/SettingsButton
@onready var pause_mainmenu_button: Button = $PauseOverlay/PauseContent/PauseButtons/MainMenuButton
@onready var char_left: TextureRect = $Characters/CharLeft
@onready var char_center: TextureRect = $Characters/CharCenter
@onready var char_right: TextureRect = $Characters/CharRight

# Systems used in VN-only flow
var sanity_system: SanitySystem
var character_manager: CharacterManager

var current_character: String = ""
var current_dialogue_step: int = 0

# Player sanity tracking
var player_sanity: float = 50.0

# Simple VN array (pure strings)
var vn_lines: Array[String] = [
	"Hi.",
	"I like this game.",
	"Dialogue works."
]
var vn_index: int = 0

func _ready():
	_initialize_systems()
	_connect_ui()
	_show_start()

func _connect_ui():
	start_button.pressed.connect(_on_start)
	test_menu_button.pressed.connect(_on_test_menu)
	quit_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
	save_back_button.pressed.connect(_hide_save)
	go_restart_button.pressed.connect(_restart_to_choice)
	go_quit_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
	# Pause overlay buttons
	pause_resume_button.pressed.connect(_toggle_pause)
	pause_settings_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/settings_scene.tscn"))
	pause_mainmenu_button.pressed.connect(func():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)

func _on_start():
	start_screen.visible = false
	_show_vn_demo()

func _show_start():
	start_screen.visible = true
	vn_text.visible = false
	dialogue_panel.visible = false
	choices_container.visible = true
	red_overlay.visible = true
	save_screen.visible = false
	game_over_screen.visible = false
	# Show a Start button (already visible in scene) and ensure clicks work

func _show_vn_demo():
	vn_index = 0
	vn_text.visible = true
	dialogue_panel.visible = false
	choices_container.visible = true
	_show_vn_line()

func _show_vn_line():
	if vn_index >= vn_lines.size():
		# End, show Start screen again or character selection; choose Start screen for now
		_show_start()
		return
	vn_text.text = vn_lines[vn_index]
	# Refresh choices to show Next
	for child in choices_container.get_children():
		child.queue_free()
	var next_btn := Button.new()
	next_btn.text = "Next" if vn_index < vn_lines.size() - 1 else "Finish"
	next_btn.custom_minimum_size = Vector2(0, 36)
	next_btn.pressed.connect(_next_vn_line)
	choices_container.add_child(next_btn)

func _next_vn_line():
	vn_index += 1
	_show_vn_line()

func _initialize_systems():
	sanity_system = SanitySystem.new()
	sanity_system.name = "SanitySystem"
	add_child(sanity_system)
	
	character_manager = CharacterManager.new()
	character_manager.name = "CharacterManager"
	add_child(character_manager)
	
	sanity_system.sanity_changed.connect(_on_sanity_changed)
	print("Novel systems initialized successfully")

func _on_sanity_changed(new_sanity: float, old_sanity: float):
	player_sanity = new_sanity

func _on_test_menu():
	start_screen.visible = false
	_show_vn_demo()

func _toggle_pause():
	var now_paused = !get_tree().paused
	get_tree().paused = now_paused
	pause_overlay.visible = now_paused

func _hide_save():
	save_screen.visible = false

func _restart_to_choice():
	_show_start()

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				_toggle_pause()
			KEY_M:
				_toggle_pause()
			KEY_H:
				vn_text.visible = !vn_text.visible
