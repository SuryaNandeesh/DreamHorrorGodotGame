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
@onready var vn_text: RichTextLabel = $DialogueContainer/VNText
@onready var name_label: Label = $DialogueContainer/NameLabel
@onready var name_background: Panel = $DialogueContainer/NameBackground
@onready var pause_overlay: Panel = $PauseOverlay
@onready var pause_resume_button: Button = $PauseOverlay/PauseContent/PauseButtons/ResumeButton
@onready var pause_settings_button: Button = $PauseOverlay/PauseContent/PauseButtons/SettingsButton
@onready var pause_mainmenu_button: Button = $PauseOverlay/PauseContent/PauseButtons/MainMenuButton
@onready var char_left: TextureRect = get_node_or_null("Characters/CharLeft")
@onready var char_center: TextureRect = get_node_or_null("Characters/CharCenter")
@onready var char_right: TextureRect = get_node_or_null("Characters/CharRight")

# Systems used in VN-only flow
@onready var sanity_system := get_node("/root/SanitySystem")
@onready var character_manager := get_node("/root/CharacterManager")
@onready var save_system := get_node("/root/SaveSystem")
@onready var settings_system := get_node("/root/SettingsSystem")

# Audio nodes
@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
var current_music: String = ""

# Menu management
var active_menu: Control = null
var active_dialog: AcceptDialog = null

# Save info type definition
class SaveInfo:
	var exists: bool = false
	var save_date: String = ""
	var player_level: int = 1
	var current_chapter: String = ""

var current_character: String = ""
var current_dialogue_step: int = 0

# Player sanity tracking
var player_sanity: float = 50.0

# Visual novel state
var dialogue_state = {
	"is_in_dialogue": false,
	"current_index": 0,
	"dialogue_visible": true,
	"animate_text": true,  # Whether text should be animated
	"animation_speed": 45.0,  # Characters per second (will be updated from settings)
	"visible_characters": 0,  # Current number of visible characters
	"current_text": "",  # Full text of current line
	"is_text_completed": false,  # Whether current text animation is done
	"is_skipping": false,  # Whether text is being skipped
	"fade_time": 0.5,  # Time in seconds for fade animations
	"current_fade": 0.0,  # Current fade value (0.0 to 1.0)
	"target_fade": 1.0,  # Target fade value
	"fade_timer": 0.0  # Timer for fade delay
}

# Visual novel dialogue structure
var vn_dialogue = [
	{
		"id": "start",
		"character": "none",
		"text": "Your car sputters to a stop on the outskirts of a small town. The fuel gauge reads empty.",
		"position": "center",
		"choices": [
			{"text": "Look around for help", "next": "look_around"},
			{"text": "Check your phone", "next": "check_phone"}
		]
	},
	{
		"id": "check_phone",
		"character": "none",
		"text": "No signal. The screen shows only a single bar, flickering in and out.",
		"position": "center",
		"next": "look_around"
	},
	{
		"id": "look_around",
		"character": "none",
		"text": "A small shop sits at the edge of town, its windows casting a warm glow in the evening light.",
		"position": "center",
		"next": "enter_shop"
	},
	{
		"id": "enter_shop",
		"character": "shopkeeper",
		"text": "Welcome, stranger. Don't get many visitors out here. I'm Helena, I run this little shop.",
		"position": "center",
		"choices": [
			{"text": "Ask about gas station", "next": "ask_gas"},
			{"text": "Ask about town", "next": "ask_town"}
		]
	},
	{
		"id": "ask_gas",
		"character": "shopkeeper",
		"text": "Gas station's closed for the night. Owner's been... unreliable lately. Strange things happening.",
		"position": "center",
		"next": "meet_elena"
	},
	{
		"id": "ask_town",
		"character": "shopkeeper",
		"text": "Ashford Valley. Small place, but... interesting. Been here longer than most can remember.",
		"position": "center",
		"next": "meet_elena"
	},
	{
		"id": "meet_elena",
		"character": "daughter",
		"text": "Helena, do you have any more of those special candles? Mom asked me to- Oh, hello there.",
		"position": "right",
		"next": "elena_intro"
	},
	{
		"id": "elena_intro",
		"character": "shopkeeper",
		"text": "Elena Ashford, meet our stranded visitor. Their car ran out of gas.",
		"position": "left",
		"choices": [
			{"text": "Nice to meet you", "next": "elena_nice"},
			{"text": "I need help", "next": "elena_help"}
		]
	},
	{
		"id": "elena_nice",
		"character": "daughter",
		"text": "Nice to meet you too! Sorry about your car. You know... our house isn't far from here. Maybe you could stay the night?",
		"position": "right",
		"next": "helena_warning"
	},
	{
		"id": "elena_help",
		"character": "daughter",
		"text": "Oh, you poor thing. Stuck here at night... Listen, we have a spare room at our house. It's not much, but it's better than sleeping in your car.",
		"position": "right",
		"next": "helena_warning"
	},
	{
		"id": "helena_warning",
		"character": "shopkeeper",
		"text": "Elena... are you sure that's wise? Your mother...",
		"position": "left",
		"next": "elena_insists"
	},
	{
		"id": "elena_insists",
		"character": "daughter",
		"text": "Mom will understand. Besides, it's not safe out here at night. Not anymore.",
		"position": "right",
		"choices": [
			{"text": "What do you mean, not safe?", "next": "ask_safety"},
			{"text": "Accept the offer", "next": "accept_stay"}
		]
	},
	{
		"id": "ask_safety",
		"character": "daughter",
		"text": "Oh, just... wild animals. And the weather can get pretty bad. Nothing to worry about really...",
		"position": "right",
		"next": "helena_concerned"
	},
	{
		"id": "accept_stay",
		"character": "daughter",
		"text": "Great! Let me just get these candles and we can head over. It's only a ten-minute walk.",
		"position": "right",
		"next": "helena_concerned"
	},
	{
		"id": "helena_concerned",
		"character": "shopkeeper",
		"text": "Just... be careful. And Elena? Tell your mother I'll be by tomorrow with those... items she requested.",
		"position": "left",
		"next": "leave_shop"
	},
	{
		"id": "leave_shop",
		"character": "none",
		"text": "You follow Elena out of the shop. The sun has almost set, casting long shadows across the empty street. In the distance, you hear what sounds like... humming?",
		"position": "center",
		"choices": [
			{"text": "Ask Elena about the humming", "next": "ask_humming"},
			{"text": "Stay quiet", "next": "walk_quiet"}
		]
	},
	{
		"id": "ask_humming",
		"character": "daughter",
		"text": "Humming? I don't... oh, that. That's probably just the wind in the old factory pipes. Nothing to worry about. Let's hurry though.",
		"position": "right",
		"next": "approach_house"
	},
	{
		"id": "walk_quiet",
		"character": "daughter",
		"text": "You notice Elena quickening her pace, her eyes darting to the shadows. She clutches the bag of candles tightly.",
		"position": "right",
		"next": "approach_house"
	},
	{
		"id": "approach_house",
		"character": "none",
		"text": "A large Victorian house looms before you, its windows dark except for a faint red glow from an upstairs room. The front porch creaks as you approach.",
		"position": "center",
		"next": "meet_mother"
	},
	{
		"id": "meet_mother",
		"character": "mother",
		"text": "Elena? Is that you? I was getting worried and... oh. Who is this?",
		"position": "center",
		"next": "elena_explains"
	},
	{
		"id": "elena_explains",
		"character": "daughter",
		"text": "Mom, this is a traveler. Their car broke down by Helena's shop. I thought they could stay in the spare room tonight.",
		"position": "right",
		"next": "mother_decision"
	},
	{
		"id": "mother_decision",
		"character": "mother",
		"text": "...",
		"position": "center",
		"choices": [
			{"text": "I can leave if it's a problem", "next": "mother_accepts"},
			{"text": "Thank you for considering", "next": "mother_accepts"}
		]
	},
	{
		"id": "mother_accepts",
		"character": "mother",
		"text": "No, no... Elena's right. It's not safe out there at night. Come in. But please, stay in your room once night falls. The house... settles strangely after dark.",
		"position": "center",
		"next": "enter_house"
	},
	{
		"id": "enter_house",
		"character": "none",
		"text": "As you step inside, you notice strange symbols carved into the doorframe, and what looks like salt lines across the threshold. The mother quickly brushes them away with her foot.",
		"position": "center",
		"next": "chapter_end"
	},
	{
		"id": "chapter_end",
		"character": "none",
		"text": "End of Chapter 1: The Arrival",
		"position": "center",
		"next": "start"
	}
]

# Character name mappings
var character_names = {
	"none": "",
	"daughter": "Elena Ashford",
	"brother": "Marcus Ashford",
	"father": "Richard Ashford",
	"mother": "Catherine Ashford",
	"shopkeeper": "Helena"
}
var vn_index: int = 0

func _ready():
	# Wait for nodes to be ready
	await get_tree().process_frame
	
	# Set process mode for the entire scene
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Initialize systems first
	_initialize_systems()
	
	# Make sure UI elements can process while paused
	if pause_overlay:
		pause_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
		pause_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
		pause_overlay.visible = false
		pause_overlay.self_modulate = Color(0.1, 0.1, 0.1, 0.9)
		
		# Make sure the pause overlay is on top
		if pause_overlay.get_parent():
			pause_overlay.get_parent().move_child(pause_overlay, -1)
		
		# Set up pause menu buttons
		var pause_content = pause_overlay.get_node("PauseContent")
		if pause_content:
			pause_content.mouse_filter = Control.MOUSE_FILTER_STOP
			for button in pause_content.get_node("PauseButtons").get_children():
				if button is Button:
					button.mouse_filter = Control.MOUSE_FILTER_STOP
	
	if choices_container:
		choices_container.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect UI after nodes are ready
	_connect_ui()
	
	# Show start screen
	_show_start()

func _connect_ui():
	# Main menu buttons
	if start_button:
		start_button.process_mode = Node.PROCESS_MODE_ALWAYS
	start_button.pressed.connect(_on_start)
	
	if test_menu_button:
		test_menu_button.process_mode = Node.PROCESS_MODE_ALWAYS
	test_menu_button.pressed.connect(_on_test_menu)
	
	if quit_button:
		quit_button.process_mode = Node.PROCESS_MODE_ALWAYS
		quit_button.pressed.connect(func(): 
			get_tree().paused = false
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		)
	
	# Save screen buttons
	if save_back_button:
		save_back_button.process_mode = Node.PROCESS_MODE_ALWAYS
	save_back_button.pressed.connect(_hide_save)
	
	# Game over buttons
	if go_restart_button:
		go_restart_button.process_mode = Node.PROCESS_MODE_ALWAYS
	go_restart_button.pressed.connect(_restart_to_choice)
	
	if go_quit_button:
		go_quit_button.process_mode = Node.PROCESS_MODE_ALWAYS
		go_quit_button.pressed.connect(func(): 
			get_tree().paused = false
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		)
	
	# Pause overlay buttons
	if pause_resume_button:
		pause_resume_button.process_mode = Node.PROCESS_MODE_ALWAYS
		pause_resume_button.pressed.connect(_toggle_pause)
	
	if pause_settings_button:
		pause_settings_button.process_mode = Node.PROCESS_MODE_ALWAYS
		pause_settings_button.pressed.connect(func(): 
			get_tree().paused = false
			var global = get_node("/root/Global")
			global.store_current_scene("res://scenes/visual_novel.tscn")
			get_tree().change_scene_to_file("res://scenes/settings_scene.tscn")
		)
	
	if pause_mainmenu_button:
		pause_mainmenu_button.process_mode = Node.PROCESS_MODE_ALWAYS
		pause_mainmenu_button.pressed.connect(func():
			get_tree().paused = false
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		)
	
	# Add save/load buttons to pause menu
	var pause_buttons = pause_overlay.get_node("PauseContent/PauseButtons")
	if pause_buttons:
		var save_button = Button.new()
		save_button.text = "Save Game"
		save_button.process_mode = Node.PROCESS_MODE_ALWAYS
		save_button.mouse_filter = Control.MOUSE_FILTER_STOP
		save_button.pressed.connect(func(): _show_save_load_screen(true))
		pause_buttons.add_child(save_button)
		pause_buttons.move_child(save_button, 1)  # After Resume
		
		var load_button = Button.new()
		load_button.text = "Load Game"
		load_button.process_mode = Node.PROCESS_MODE_ALWAYS
		load_button.mouse_filter = Control.MOUSE_FILTER_STOP
		load_button.pressed.connect(func(): _show_save_load_screen(false))
		pause_buttons.add_child(load_button)
		pause_buttons.move_child(load_button, 2)  # After Save
	
	print("UI connections established")

func _on_start():
	start_screen.visible = false
	_show_vn_demo()

func _show_start():
	# Close any existing menus
	_close_active_menus()
	
	# Reset all UI states
	if vn_text:
		vn_text.visible = false
	if dialogue_panel:
		dialogue_panel.visible = false
	if choices_container:
		choices_container.visible = false
	if name_label:
		name_label.visible = false
	if name_background:
		name_background.visible = false
	if red_overlay:
		red_overlay.visible = true
	
	# Set up and show start screen
	start_screen.visible = true
	start_screen.show()
	start_screen.move_to_front()
	active_menu = start_screen
	
	# Ensure buttons are interactive
	start_button.mouse_filter = Control.MOUSE_FILTER_STOP
	test_menu_button.mouse_filter = Control.MOUSE_FILTER_STOP
	quit_button.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Reset game state
	get_tree().paused = false

func _show_vn_demo():
	vn_index = dialogue_state.current_index if dialogue_state.is_in_dialogue else 0
	vn_text.visible = dialogue_state.dialogue_visible
	dialogue_panel.visible = false
	choices_container.visible = true
	dialogue_state.is_in_dialogue = true
	_hide_all_characters()
	_show_vn_line()

func _show_vn_line():
	if vn_index >= vn_dialogue.size():
		# End, show Start screen again
		_hide_all_characters()
		_show_start()
		return
	
	var line = vn_dialogue[vn_index]
	
	# Store the full text and reset animation state
	var end_marker = "■"
	if line.has("choices"):
		end_marker = "▼"
	elif line.has("next"):
		end_marker = "▼"
	dialogue_state.current_text = line.text + "\n\n" + end_marker
	dialogue_state.visible_characters = 0
	dialogue_state.is_text_completed = false
	dialogue_state.is_skipping = false
	dialogue_state.target_fade = 1.0  # Start fade in
	dialogue_state.fade_timer = 0.0  # Reset fade timer
	
	# Always set the text first
	vn_text.text = dialogue_state.current_text
	
	if dialogue_state.animate_text:
		vn_text.visible_characters = 0
	else:
		vn_text.visible_characters = -1  # Show all characters
		dialogue_state.is_text_completed = true
	
	# Show character portrait
	_hide_all_characters()
	if line.character != "none":
		var char_image = load("res://images/" + line.character + ".png")
		match line.position:
			"left":
				if char_left:
					char_left.texture = char_image
					char_left.visible = true
			"center":
				if char_center:
					char_center.texture = char_image
					char_center.visible = true
			"right":
				if char_right:
					char_right.texture = char_image
					char_right.visible = true
	
	# Show character name
	if name_label and name_background:
		name_label.text = character_names[line.character]
		name_label.visible = line.character != "none"
		name_background.visible = line.character != "none"
		name_label.modulate.a = dialogue_state.current_fade  # Apply fade to name label
		name_background.modulate.a = dialogue_state.current_fade  # Apply fade to name background
	
	# Clear any existing choices
	for child in choices_container.get_children():
		child.queue_free()
	
	# Show choices if available
	if line.has("choices"):
		for choice in line.choices:
			var button = Button.new()
			button.text = choice.text
			button.pressed.connect(func(): _on_choice_selected(choice.next))
			choices_container.add_child(button)
		choices_container.visible = true
	
	# Make sure UI is visible
	vn_text.visible = dialogue_state.dialogue_visible

func _hide_all_characters():
	if char_left:
		char_left.visible = false
	if char_center:
		char_center.visible = false
	if char_right:
		char_right.visible = false
	if name_label:
		name_label.visible = false
	if name_background:
		name_background.visible = false

func _next_vn_line():
	var line = vn_dialogue[vn_index]
	
	# If this line has choices and they're not shown yet, show them
	if line.has("choices") and not choices_container.visible:
		choices_container.visible = true
		return
	
	# If choices are visible, don't advance
	if choices_container.visible:
		return
	
	# If this line has a next ID, jump to that line
	if line.has("next"):
		_jump_to_line(line.next)
		return
	
	# Otherwise, go to next sequential line
	vn_index += 1
	dialogue_state.current_index = vn_index
	_show_vn_line()

func _jump_to_line(id: String):
	for i in range(vn_dialogue.size()):
		if vn_dialogue[i].id == id:
			vn_index = i
			dialogue_state.current_index = vn_index
			_show_vn_line()
			return

func _on_choice_selected(next_id: String):
	choices_container.visible = false
	_jump_to_line(next_id)

func _initialize_systems():
	# Initialize audio system
	add_child(music_player)
	music_player.bus = "Music"
	_update_music_volume()
	
	# Load text speed from settings
	dialogue_state.animation_speed = settings_system.get_gameplay_setting("text_speed")
	
	# Connect to settings changes
	settings_system.setting_changed.connect(_on_setting_changed)
	sanity_system.sanity_changed.connect(_on_sanity_changed)
	print("Novel systems initialized successfully")
	
	# Start background music
	_play_music("res://audio/music/main_theme.ogg")

func _on_setting_changed(category: String, setting: String, value):
	if category == "gameplay" and setting == "text_speed":
		dialogue_state.animation_speed = value
	elif category == "audio":
		if setting == "music_volume" or setting == "master_volume":
			_update_music_volume()
		elif setting == "enable_music":
			music_player.stream_paused = !value

func _update_music_volume():
	if settings_system and music_player:
		var master_volume = settings_system.get_audio_volume("master")
		var music_volume = settings_system.get_audio_volume("music")
		var music_enabled = settings_system.is_audio_enabled("music")
		music_player.volume_db = linear_to_db(master_volume * music_volume)
		music_player.stream_paused = !music_enabled

func _play_music(path: String):
	if path == current_music:
		return
		
	current_music = path
	if ResourceLoader.exists(path):
		var stream = load(path)
		if stream:
			music_player.stream = stream
			music_player.play()
			_update_music_volume()

func _on_sanity_changed(new_sanity: float, _old_sanity: float):
	player_sanity = new_sanity

func _on_test_menu():
	start_screen.visible = false
	_show_vn_demo()

func _toggle_pause():
	var now_paused = !get_tree().paused
	
	if now_paused:
		# Close any existing menus first
		_close_active_menus()
		
		# Show pause menu
		pause_overlay.visible = true
		pause_overlay.show()
		pause_overlay.move_to_front()
		active_menu = pause_overlay
		
		# Make sure all pause menu buttons are interactive
		pause_resume_button.mouse_filter = Control.MOUSE_FILTER_STOP
		pause_settings_button.mouse_filter = Control.MOUSE_FILTER_STOP
		pause_mainmenu_button.mouse_filter = Control.MOUSE_FILTER_STOP
		
		# Make sure the pause menu container is in front
		var pause_content = pause_overlay.get_node("PauseContent")
		if pause_content:
			pause_content.show()
			pause_content.mouse_filter = Control.MOUSE_FILTER_STOP
			
		# Make sure the pause overlay is on top
		if pause_overlay.get_parent():
			pause_overlay.get_parent().move_child(pause_overlay, -1)
	else:
		_close_active_menus()
	
	get_tree().paused = now_paused

func _close_active_menus():
	# Close any active dialog
	if active_dialog != null:
		active_dialog.hide()
		active_dialog.queue_free()
		active_dialog = null
	
	# Hide any active menu
	if active_menu != null:
		active_menu.hide()
		active_menu = null
	
	# Hide all main menus
	start_screen.visible = false
	save_screen.visible = false
	game_over_screen.visible = false
	pause_overlay.visible = false

func _save_dialogue_state():
	# Store current dialogue state
	var prev_state = dialogue_state.duplicate()
	prev_state.visible_elements = {
		"vn_text": vn_text.visible,
		"dialogue_panel": dialogue_panel.visible,
		"choices_container": choices_container.visible,
		"char_left": char_left.visible,
		"char_center": char_center.visible,
		"char_right": char_right.visible
	}
	return prev_state

func _restore_dialogue_state(state):
	if state == null:
		return
	
	dialogue_state = state
	if state.has("visible_elements"):
		vn_text.visible = state.visible_elements.vn_text
		dialogue_panel.visible = state.visible_elements.dialogue_panel
		choices_container.visible = state.visible_elements.choices_container
		char_left.visible = state.visible_elements.char_left
		char_center.visible = state.visible_elements.char_center
		char_right.visible = state.visible_elements.char_right
	
	if state.is_in_dialogue:
		_show_vn_line()

func _show_save_load_screen(is_save: bool):
	# If a dialog is already showing, queue this operation
	if active_dialog != null:
		# Close existing dialog first
		active_dialog.hide()
		active_dialog.queue_free()
		active_dialog = null
		await get_tree().process_frame
	
	# Store current state before showing save dialog
	var prev_state = _save_dialogue_state()
	
	# Close any existing menus first
	_close_active_menus()
	
	# Create save/load dialog
	var dlg := AcceptDialog.new()
	dlg.title = "Save Game" if is_save else "Load Game"
	dlg.process_mode = Node.PROCESS_MODE_ALWAYS
	dlg.exclusive = true
	
	# Connect close signal to restore state and cleanup
	dlg.close_requested.connect(func():
		active_dialog = null
		_restore_dialogue_state(prev_state)
		dlg.queue_free()
	)
	
	# Set as active dialog
	active_dialog = dlg
	
	# Create container for save slots
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(400, 300)
	dlg.add_child(scroll)
	
	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(380, 0)
	scroll.add_child(vbox)
	
	# Add save slots
	for i in range(1, 6):  # 5 save slots
		var current_slot = i  # Store slot number for closure
		var slot_container := HBoxContainer.new()
		vbox.add_child(slot_container)
		
		# Save slot info
		var info: SaveInfo = SaveInfo.new()
		var save_data = save_system.get_save_info(current_slot)
		if save_data != null:
			info.exists = true
			info.save_date = save_data.get("save_date", "Unknown Date")
			info.player_level = save_data.get("player_level", 1)
			info.current_chapter = save_data.get("current_chapter", "")
		
		var label := Label.new()
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.text = "Slot " + str(current_slot) + " - " + (info.save_date if info.exists else "Empty")
		slot_container.add_child(label)
		
		# Save/Load button
		var btn := Button.new()
		btn.text = "Save" if is_save else "Load"
		btn.disabled = !is_save and !info.exists
		
		# Create save callback
		var save_callback = func():
			if save_system.save_game(current_slot):
				dlg.queue_free()
				_show_message("Game saved to slot " + str(current_slot))
			else:
				_show_message("Failed to save game!")
		
		# Create load callback
		var load_callback = func():
			if save_system.load_game(current_slot):
				dlg.queue_free()
				_show_message("Game loaded from slot " + str(current_slot))
				get_tree().paused = false
				_show_vn_demo()  # Restart VN with loaded data
			else:
				_show_message("Failed to load game!")
		
		# Connect appropriate callback
		btn.pressed.connect(save_callback if is_save else load_callback)
		slot_container.add_child(btn)
		
		# Delete button (only show for existing saves)
		if info.exists:
			var del_btn := Button.new()
			del_btn.text = "Delete"
			
			# Create delete callback
			var delete_callback = func():
				if save_system.delete_save(current_slot):
					label.text = "Slot " + str(current_slot) + " - Empty"
					btn.disabled = !is_save
					del_btn.queue_free()
					_show_message("Save deleted!")
				else:
					_show_message("Failed to delete save!")
			
			del_btn.pressed.connect(delete_callback)
			slot_container.add_child(del_btn)
	
	# Add dialog to scene and show it
	add_child(dlg)
	dlg.popup_centered()

var pending_messages: Array = []
var is_showing_message: bool = false

func _show_message(text: String):
	# If a dialog is already showing, queue this message
	if active_dialog != null:
		pending_messages.append(text)
		return
	
	# Close any existing dialogs first
	if active_dialog != null:
		active_dialog.hide()
		active_dialog.queue_free()
		active_dialog = null
		await get_tree().process_frame
	
	# Show message immediately if no dialog is active
	var msg := AcceptDialog.new()
	msg.process_mode = Node.PROCESS_MODE_ALWAYS
	msg.dialog_text = text
	msg.exclusive = true
	
	# Set as active dialog
	active_dialog = msg
	
	# Connect close signal to process next message
	msg.close_requested.connect(func():
		active_dialog = null
		msg.queue_free()
		if pending_messages.size() > 0:
			var next_message = pending_messages[0]
			pending_messages.remove_at(0)
			_show_message(next_message)
	)
	
	add_child(msg)
	msg.popup_centered()

func _hide_save():
	save_screen.visible = false

func _restart_to_choice():
	_show_start()

func _process(delta: float):
	# Handle text animation
	if dialogue_state.animate_text and not dialogue_state.is_text_completed:
		if dialogue_state.is_skipping:
			# Show all text immediately when skipping
			dialogue_state.visible_characters = dialogue_state.current_text.length()
			vn_text.visible_characters = -1  # Show all characters
			dialogue_state.is_text_completed = true
			dialogue_state.is_skipping = false
		else:
			# Calculate how many characters to show based on time
			var chars_to_show = int(dialogue_state.animation_speed * delta)
			if chars_to_show < 1:
				chars_to_show = 1  # Show at least one character per frame
			
			dialogue_state.visible_characters += chars_to_show
			
			# Check if we've shown all characters
			if dialogue_state.visible_characters >= dialogue_state.current_text.length():
				dialogue_state.visible_characters = dialogue_state.current_text.length()
				dialogue_state.is_text_completed = true
				vn_text.visible_characters = -1  # Show all characters
			else:
				vn_text.visible_characters = dialogue_state.visible_characters
	
	# Handle dialogue box fading
	if dialogue_state.current_fade != dialogue_state.target_fade:
		var fade_speed = 1.0 / dialogue_state.fade_time
		if dialogue_state.current_fade < dialogue_state.target_fade:
			dialogue_state.current_fade = minf(dialogue_state.current_fade + fade_speed * delta, dialogue_state.target_fade)
		else:
			dialogue_state.current_fade = maxf(dialogue_state.current_fade - fade_speed * delta, dialogue_state.target_fade)
		
		# Apply fade to dialogue elements
		vn_text.modulate.a = dialogue_state.current_fade
		name_label.modulate.a = dialogue_state.current_fade
		name_background.modulate.a = dialogue_state.current_fade
	
	# Keep dialogue visible
	dialogue_state.target_fade = 1.0

func _can_advance_dialogue() -> bool:
	# Can only advance if text animation is complete or text animation is disabled
	var can_advance = dialogue_state.is_text_completed or not dialogue_state.animate_text
	return dialogue_state.is_in_dialogue and not get_tree().paused and active_dialog == null and can_advance

func _unhandled_input(event):
	# Handle mouse click
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if dialogue_state.animate_text and not dialogue_state.is_text_completed:
			# If text is still animating, show full text immediately
			dialogue_state.is_skipping = true
			get_viewport().set_input_as_handled()
		elif _can_advance_dialogue():
			_next_vn_line()
			get_viewport().set_input_as_handled()
		return
	
	# Handle keyboard input for next line
	if event.is_action_pressed("next_line"):
		if dialogue_state.animate_text and not dialogue_state.is_text_completed:
			# If text is still animating, show full text immediately
			dialogue_state.is_skipping = true
			get_viewport().set_input_as_handled()
		elif _can_advance_dialogue():
			_next_vn_line()
			get_viewport().set_input_as_handled()
		return
	
	# Skip text while holding Ctrl
	if event is InputEventKey:
		if event.keycode == KEY_CTRL:
			dialogue_state.is_skipping = event.pressed
			get_viewport().set_input_as_handled()
		return
	
	# Handle keyboard input
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				_toggle_pause()
			KEY_M:
				_toggle_pause()
			KEY_H:
				vn_text.visible = !vn_text.visible
				dialogue_state.dialogue_visible = vn_text.visible
			KEY_F5:  # Quick save to slot 1
				var prev_state = _save_dialogue_state()
				if save_system.save_game(1):
					_show_message("Quick save successful!")
				else:
					_show_message("Quick save failed!")
				_restore_dialogue_state(prev_state)
			KEY_F9:  # Quick load from slot 1
				if save_system.has_save_file(1):
					if save_system.load_game(1):
						_show_message("Quick load successful!")
						get_tree().paused = false
						_show_vn_demo()  # Restart VN with loaded data
					else:
						_show_message("Quick load failed!")
				else:
					_show_message("No quick save found!")
