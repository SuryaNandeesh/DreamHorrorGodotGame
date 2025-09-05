extends Node

# Sanity system that affects story paths and character interactions
# This is an autoload singleton, do not use class_name

# Sanity levels and their effects
enum SanityLevel {INSANE, LOW, MEDIUM, HIGH, PURE}

# Current sanity value (hidden from player)
var current_sanity: float = 50.0
var max_sanity: float = 100.0
var min_sanity: float = 0.0

# Sanity thresholds for different levels
var sanity_thresholds: Dictionary = {
	SanityLevel.INSANE: 20.0,    # Below 20: extreme paranoia, violence unlocked
	SanityLevel.LOW: 35.0,       # Below 35: paranoia, dark topics unlocked
	SanityLevel.MEDIUM: 65.0,    # Below 65: normal behavior
	SanityLevel.HIGH: 80.0,      # Above 80: positive outlook, moral guidance
	SanityLevel.PURE: 100.0      # 100: pure, blocked from dark topics
}

# Sanity modifiers for different actions
var sanity_modifiers: Dictionary = {
	# Positive actions (increase sanity)
	"help_character": 5.0,
	"show_empathy": 3.0,
	"resolve_conflict_peacefully": 4.0,
	"support_family": 6.0,
	"avoid_violence": 2.0,
	"show_trust": 3.0,
	"listen_to_family": 2.0,
	"offer_comfort": 4.0,
	"share_positive_memory": 3.0,
	"show_patience": 2.0,
	
	# Negative actions (decrease sanity)
	"bully_character": -8.0,
	"show_aggression": -5.0,
	"escalate_conflict": -6.0,
	"betray_trust": -10.0,
	"witness_horror": -15.0,
	"commit_violence": -20.0,
	"discover_dark_secret": -12.0,
	"experience_trauma": -25.0,
	"ignore_family": -3.0,
	"spread_rumors": -5.0,
	"break_promises": -7.0,
	"show_disrespect": -4.0,
	
	# Environmental factors (only triggered by specific events)
	"dark_environment": -2.0,
	"isolation": -1.0,
	"family_support": 3.0,
	"positive_interaction": 2.0,
	"witness_family_conflict": -3.0,
	"discover_hidden_weapons": -8.0,
	"hear_whispers": -5.0,
	"see_shadows": -3.0,
	
	# Story choice modifiers
	"choose_violent_path": -10.0,
	"choose_peaceful_path": 5.0,
	"investigate_mystery": -5.0,
	"avoid_mystery": 2.0,
	"confront_character": -3.0,
	"support_character": 4.0,
	"betray_character": -15.0,
	"protect_character": 6.0
}

# Story path restrictions based on sanity
var story_path_restrictions: Dictionary = {
	SanityLevel.INSANE: {
		"unlocked": ["violence", "dark_secrets", "paranoia", "isolation", "aggression"],
		"blocked": ["family_values", "moral_guidance", "trust", "empathy"],
		"character_behavior": {
			"mother": "Extremely paranoid, hides everything, may become violent",
			"brother": "Completely withdrawn, may attack player",
			"daughter": "Aggressive, easily manipulated, violent tendencies",
			"father": "Confrontational, suspicious, may become abusive"
		}
	},
	SanityLevel.LOW: {
		"unlocked": ["drugs", "illegal_acts", "violence", "dark_secrets", "paranoia"],
		"blocked": ["family_values", "moral_guidance", "positive_outlook"],
		"character_behavior": {
			"mother": "Hides weapons, becomes paranoid, suspicious",
			"brother": "Withdraws, avoids player, may share dark secrets",
			"daughter": "Easily manipulated, aggressive, vulnerable",
			"father": "Irritable, confrontational, may share dark interests"
		}
	},
	SanityLevel.MEDIUM: {
		"unlocked": ["casual_conversation", "family_matters", "daily_life"],
		"blocked": ["extreme_topics", "deep_secrets"],
		"character_behavior": {
			"mother": "Normal behavior, some mystery maintained",
			"brother": "Casual interaction, some distance",
			"daughter": "Normal behavior, some vulnerability",
			"father": "Normal behavior, tired but friendly"
		}
	},
	SanityLevel.HIGH: {
		"unlocked": ["family_values", "moral_guidance", "positive_outlook", "deep_connections"],
		"blocked": ["drugs", "illegal_acts", "violence", "dark_secrets"],
		"character_behavior": {
			"mother": "More open about past, trusting, supportive",
			"brother": "Open, supportive, helpful, may share positive experiences",
			"daughter": "Confident, protective, strong, supportive",
			"father": "Very supportive, enthusiastic, open, protective"
		}
	},
	SanityLevel.PURE: {
		"unlocked": ["family_values", "moral_guidance", "positive_outlook", "deep_connections", "spiritual_guidance"],
		"blocked": ["drugs", "illegal_acts", "violence", "dark_secrets", "negative_emotions"],
		"character_behavior": {
			"mother": "Completely open, spiritual guide, protective",
			"brother": "Deeply supportive, mentor figure, positive influence",
			"daughter": "Strong leader, protective, inspiring",
			"father": "Pillar of strength, wise, completely supportive"
		}
	}
}

# Dialogue modifiers based on sanity
var dialogue_modifiers: Dictionary = {
	SanityLevel.INSANE: {
		"tone": "aggressive",
		"word_choice": "violent",
		"empathy": "none",
		"patience": "none"
	},
	SanityLevel.LOW: {
		"tone": "suspicious",
		"word_choice": "dark",
		"empathy": "low",
		"patience": "low"
	},
	SanityLevel.MEDIUM: {
		"tone": "neutral",
		"word_choice": "normal",
		"empathy": "medium",
		"patience": "medium"
	},
	SanityLevel.HIGH: {
		"tone": "supportive",
		"word_choice": "positive",
		"empathy": "high",
		"patience": "high"
	},
	SanityLevel.PURE: {
		"tone": "inspiring",
		"word_choice": "uplifting",
		"empathy": "maximum",
		"patience": "maximum"
	}
}

# Signals
signal sanity_changed(new_sanity: float, old_sanity: float)
signal sanity_level_changed(new_level: SanityLevel, old_level: SanityLevel)
# signal _story_path_unlocked(path: String)  # Unused signal
# signal _story_path_blocked(path: String)  # Unused signal

func _ready():
	# Connect to game manager if available
	if Engine.has_singleton("GameManager"):
		var game_manager = Engine.get_singleton("GameManager")
		if game_manager.has("sanity_level"):
			game_manager.sanity_level = current_sanity

# Removed automatic sanity decay - sanity now only changes through specific actions

func get_current_sanity() -> float:
	return current_sanity

func get_sanity_level() -> SanityLevel:
	if current_sanity < sanity_thresholds[SanityLevel.INSANE]:
		return SanityLevel.INSANE
	elif current_sanity < sanity_thresholds[SanityLevel.LOW]:
		return SanityLevel.LOW
	elif current_sanity < sanity_thresholds[SanityLevel.MEDIUM]:
		return SanityLevel.MEDIUM
	elif current_sanity < sanity_thresholds[SanityLevel.HIGH]:
		return SanityLevel.HIGH
	else:
		return SanityLevel.PURE

func modify_sanity(amount: float):
	var old_sanity = current_sanity
	var old_level = get_sanity_level()
	
	current_sanity = clamp(current_sanity + amount, min_sanity, max_sanity)
	
	var new_level = get_sanity_level()
	
	# Emit signals
	sanity_changed.emit(current_sanity, old_sanity)
	
	if new_level != old_level:
		sanity_level_changed.emit(new_level, old_level)
		_handle_level_change(new_level, old_level)
	
	# Update game manager if available
	if Engine.has_singleton("GameManager"):
		var game_manager = Engine.get_singleton("GameManager")
		if game_manager.has("sanity_level"):
			game_manager.sanity_level = current_sanity

func apply_action_modifier(action: String):
	var modifier = sanity_modifiers.get(action, 0.0)
	if modifier != 0.0:
		modify_sanity(modifier)
		print("Sanity modified by ", modifier, " for action: ", action)
		return true
	else:
		print("No sanity modifier found for action: ", action)
		return false

# New method for applying multiple action modifiers at once
func apply_multiple_actions(actions: Array):
	var total_change = 0.0
	for action in actions:
		var modifier = sanity_modifiers.get(action, 0.0)
		total_change += modifier
		print("Action: ", action, " - Modifier: ", modifier)
	
	if total_change != 0.0:
		modify_sanity(total_change)
		print("Total sanity change: ", total_change)
		return true
	return false

# Method to manually set sanity to a specific level (useful for testing)
func set_sanity_level(level: SanityLevel):
	var target_sanity = sanity_thresholds[level]
	var difference = target_sanity - current_sanity
	modify_sanity(difference)
	print("Sanity manually set to level: ", level, " (", target_sanity, ")")

# Method to reset sanity to medium level (useful for testing)
func reset_sanity_to_medium():
	var target_sanity = sanity_thresholds[SanityLevel.MEDIUM]
	var difference = target_sanity - current_sanity
	modify_sanity(difference)
	print("Sanity reset to medium level: ", target_sanity)

# Method to get available actions for current sanity level
func get_available_actions() -> Array:
	var available_actions = []
	var current_level = get_sanity_level()
	
	# Add actions based on current sanity level
	match current_level:
		SanityLevel.INSANE, SanityLevel.LOW:
			# Dark actions available
			available_actions.append("choose_violent_path")
			available_actions.append("investigate_mystery")
			available_actions.append("confront_character")
			available_actions.append("betray_character")
		SanityLevel.MEDIUM:
			# Balanced actions
			available_actions.append("choose_peaceful_path")
			available_actions.append("investigate_mystery")
			available_actions.append("support_character")
			available_actions.append("avoid_mystery")
		SanityLevel.HIGH, SanityLevel.PURE:
			# Positive actions only
			available_actions.append("choose_peaceful_path")
			available_actions.append("support_character")
			available_actions.append("protect_character")
			available_actions.append("avoid_mystery")
	
	# Always available actions
	available_actions.append("help_character")
	available_actions.append("show_empathy")
	available_actions.append("listen_to_family")
	available_actions.append("show_patience")
	
	return available_actions

# Method to check if an action is available at current sanity level
func can_perform_action(action: String) -> bool:
	var available_actions = get_available_actions()
	return available_actions.has(action)

# Method to get sanity change preview for an action (without applying it)
func get_sanity_change_preview(action: String) -> float:
	return sanity_modifiers.get(action, 0.0)

# Method to get sanity change preview for multiple actions
func get_multiple_actions_preview(actions: Array) -> float:
	var total_change = 0.0
	for action in actions:
		total_change += sanity_modifiers.get(action, 0.0)
	return total_change

# Method to temporarily boost sanity (useful for story events)
func temporary_sanity_boost(amount: float, duration: float = 10.0):
	var _old_sanity = current_sanity
	modify_sanity(amount)
	print("Temporary sanity boost: +", amount, " for ", duration, " seconds")
	
	# Schedule a timer to remove the boost
	var timer = get_tree().create_timer(duration)
	timer.timeout.connect(func(): 
		modify_sanity(-amount)
		print("Temporary sanity boost expired: -", amount)
	)

func can_access_story_path(path: String) -> bool:
	var current_level = get_sanity_level()
	var restrictions = story_path_restrictions.get(current_level, {})
	var unlocked_paths = restrictions.get("unlocked", [])
	
	return unlocked_paths.has(path)

func get_blocked_story_paths() -> Array:
	var current_level = get_sanity_level()
	var restrictions = story_path_restrictions.get(current_level, {})
	return restrictions.get("blocked", [])

func get_character_behavior_change(character_id: String) -> String:
	var current_level = get_sanity_level()
	var restrictions = story_path_restrictions.get(current_level, {})
	var behaviors = restrictions.get("character_behavior", {})
	
	return behaviors.get(character_id, "Normal behavior")

func get_dialogue_modifier() -> Dictionary:
	var current_level = get_sanity_level()
	return dialogue_modifiers.get(current_level, dialogue_modifiers[SanityLevel.MEDIUM])

func is_topic_accessible(topic: String) -> bool:
	# Check if the topic is blocked by current sanity level
	var blocked_paths = get_blocked_story_paths()
	return not blocked_paths.has(topic)

func get_sanity_description() -> String:
	var level = get_sanity_level()
	match level:
		SanityLevel.INSANE:
			return "Your mind is fractured. Reality seems distant, and dark thoughts consume you."
		SanityLevel.LOW:
			return "You feel uneasy. The world seems darker, and you're more suspicious of others."
		SanityLevel.MEDIUM:
			return "You feel relatively stable, though there's an underlying tension."
		SanityLevel.HIGH:
			return "You feel clear-headed and optimistic. The world seems brighter."
		SanityLevel.PURE:
			return "Your mind is clear and pure. You radiate positive energy and wisdom."
		_:
			return "Your mental state is unclear."

func get_sanity_effects() -> Array:
	var level = get_sanity_level()
	var restrictions = story_path_restrictions.get(level, {})
	var effects = []
	
	# Add unlocked paths
	var unlocked = restrictions.get("unlocked", [])
	for path in unlocked:
		effects.append("Unlocked: " + path.replace("_", " ").capitalize())
	
	# Add blocked paths
	var blocked = restrictions.get("blocked", [])
	for path in blocked:
		effects.append("Blocked: " + path.replace("_", " ").capitalize())
	
	return effects

func _handle_level_change(new_level: SanityLevel, _old_level: SanityLevel):
	# Handle specific level change effects
	match new_level:
		SanityLevel.INSANE:
			_handle_insane_level()
		SanityLevel.LOW:
			_handle_low_level()
		SanityLevel.HIGH:
			_handle_high_level()
		SanityLevel.PURE:
			_handle_pure_level()

func _handle_insane_level():
	# Unlock extreme content, change world atmosphere
	print("Warning: Player has reached insane sanity level")
	# Could trigger special events, change music, etc.

func _handle_low_level():
	# Unlock dark content, change character behaviors
	print("Player sanity has dropped to low level")
	# Could trigger paranoia events, change dialogue options

func _handle_high_level():
	# Unlock positive content, improve character relationships
	print("Player sanity has improved to high level")
	# Could trigger positive events, improve dialogue options

func _handle_pure_level():
	# Maximum positive content, unlock spiritual guidance
	print("Player has achieved pure sanity level")
	# Could trigger special positive endings, unlock hidden content

# Public methods for external systems
func get_sanity_percentage() -> float:
	return (current_sanity / max_sanity) * 100.0

func is_sanity_critical() -> bool:
	return current_sanity < sanity_thresholds[SanityLevel.LOW]

func is_sanity_excellent() -> bool:
	return current_sanity > sanity_thresholds[SanityLevel.HIGH]
