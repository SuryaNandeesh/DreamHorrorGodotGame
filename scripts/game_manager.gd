extends Node

# Game States
enum GameState {MENU, PLAYING, PAUSED, COMBAT, DIALOGUE, GAME_OVER}
enum WorldType {REALITY, DREAM}

# Current game state
var current_state: GameState = GameState.MENU
var current_world: WorldType = WorldType.REALITY

# Player and party data
var player_data: Dictionary = {}
var party_members: Array = []
var vtuber_party: Array = []  # Only exists in dream world

# Game progression
var current_level: int = 1
var save_data: Dictionary = {}
var total_deaths: int = 0
var total_runs: int = 0

# Horror elements
var sanity_level: float = 100.0
var mutations: Array = []
var bad_ends: Array = []

# Signals
signal world_changed(world_type: WorldType)
signal game_state_changed(new_state: GameState)
signal party_updated()
signal sanity_changed(new_sanity: float)
signal character_mutated(character_id: String, mutation: Dictionary)

func _ready():
	# Make this a singleton
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Register with Global autoload
	if Engine.has_singleton("Global"):
		var global = Engine.get_singleton("Global")
		global.set_game_manager(self)
		print("GameManager registered with Global autoload")
	else:
		print("Global autoload not found")
	
func switch_world():
	if current_world == WorldType.REALITY:
		current_world = WorldType.DREAM
		# Add vtuber party members in dream world
		_add_vtuber_party()
	else:
		current_world = WorldType.REALITY
		# Remove vtuber party members in reality
		_remove_vtuber_party()
	
	world_changed.emit(current_world)

func _add_vtuber_party():
	# Add vtuber characters to party in dream world
	vtuber_party = [
		{"id": "vtuber_1", "name": "Luna", "type": "vtuber", "stats": {"attack": 15, "defense": 8, "speed": 12}},
		{"id": "vtuber_2", "name": "Shadow", "type": "vtuber", "stats": {"attack": 12, "defense": 10, "speed": 15}},
		{"id": "vtuber_3", "name": "Echo", "type": "vtuber", "stats": {"attack": 18, "defense": 6, "speed": 10}}
	]
	party_updated.emit()

func _remove_vtuber_party():
	vtuber_party.clear()
	party_updated.emit()

func get_current_party() -> Array:
	var full_party = party_members.duplicate()
	if current_world == WorldType.DREAM:
		full_party.append_array(vtuber_party)
	return full_party

func start_combat(enemy_data: Dictionary):
	current_state = GameState.COMBAT
	game_state_changed.emit(current_state)
	
	# Initialize combat with current party
	var combat_party = get_current_party()
	# Combat logic will be handled by CombatManager

func end_combat(victory: bool):
	if victory:
		current_state = GameState.PLAYING
	else:
		# Handle party wipe
		_handle_party_wipe()
	
	game_state_changed.emit(current_state)

func _handle_party_wipe():
	# Monster looks at player before screen goes black
	# This will be handled by the UI/visual effects
	total_deaths += 1
	save_game()
	
	# Show death screen with run summary
	current_state = GameState.GAME_OVER
	game_state_changed.emit(current_state)

func change_sanity(amount: float):
	sanity_level = clamp(sanity_level + amount, 0.0, 100.0)
	sanity_changed.emit(sanity_level)
	
	# Check for sanity-based mutations
	if sanity_level < 30.0:
		_trigger_sanity_mutation()

func _trigger_sanity_mutation():
	# Randomly mutate a party member when sanity is low
	if party_members.size() > 0:
		var random_member = party_members[randi() % party_members.size()]
		var mutation = _generate_mutation()
		random_member["mutations"] = random_member.get("mutations", [])
		random_member["mutations"].append(mutation)
		character_mutated.emit(random_member["id"], mutation)

func _generate_mutation() -> Dictionary:
	var mutations = [
		{"type": "physical", "name": "Twisted Limbs", "effect": "speed_penalty"},
		{"type": "mental", "name": "Paranoia", "effect": "attack_boost"},
		{"type": "visual", "name": "Shadow Form", "effect": "stealth_boost"},
		{"type": "audio", "name": "Echo Voice", "effect": "sanity_drain"}
	]
	return mutations[randi() % mutations.size()]

func save_game():
	save_data = {
		"player_data": player_data,
		"party_members": party_members,
		"current_level": current_level,
		"sanity_level": sanity_level,
		"total_deaths": total_deaths,
		"total_runs": total_runs,
		"mutations": mutations,
		"bad_ends": bad_ends
	}
	
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	save_file.store_string(JSON.stringify(save_data))

func load_game():
	if FileAccess.file_exists("user://savegame.save"):
		var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
		var json_string = save_file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			save_data = json.data
			player_data = save_data.get("player_data", {})
			party_members = save_data.get("party_members", [])
			current_level = save_data.get("current_level", 1)
			sanity_level = save_data.get("sanity_level", 100.0)
			total_deaths = save_data.get("total_deaths", 0)
			total_runs = save_data.get("total_runs", 0)
			mutations = save_data.get("mutations", [])
			bad_ends = save_data.get("bad_ends", [])

func new_game():
	# Reset all game data
	player_data = {}
	party_members = []
	vtuber_party = []
	current_level = 1
	sanity_level = 100.0
	mutations = []
	bad_ends = []
	total_runs += 1
	
	# Add starting party member
	party_members.append({
		"id": "player",
		"name": "You",
		"type": "player",
		"stats": {"attack": 10, "defense": 10, "speed": 10},
		"mutations": []
	})
	
	current_state = GameState.PLAYING
	game_state_changed.emit(current_state) 
