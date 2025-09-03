extends Node

# Character manager for handling character interactions and combat initiation
class_name CharacterManager

# Character definitions with personalities and sanity thresholds
var characters: Dictionary = {
	"daughter": {
		"name": "Pincushion Daughter",
		"personality": "Strong exterior, easily influenced by close relationships",
		"appearance": "Tomboy, tough-looking but vulnerable inside",
		"background": "Your younger sister who's been through some tough times. She puts on a brave face but struggles with confidence and trust issues.",
		"current_state": "Trying to find her place in the family while dealing with teenage challenges and emotional vulnerability.",
		"sanity_thresholds": {
			"low": 30.0,      # Below this: easily manipulated, aggressive
			"medium": 60.0,   # Normal behavior
			"high": 80.0      # Above this: confident, protective
		},
		"dialogue_variants": {
			"low_sanity": {
				"greeting": "What do you want?",
				"casual": "Leave me alone.",
				"intense_topic": "I don't care about that stuff."
			},
			"medium_sanity": {
				"greeting": "Hey there.",
				"casual": "What's up?",
				"intense_topic": "I'm not sure about that..."
			},
			"high_sanity": {
				"greeting": "Hello! How are you doing?",
				"casual": "Want to hang out?",
				"intense_topic": "That sounds interesting, tell me more."
			}
		}
	},
	
	"brother": {
		"name": "College Brother",
		"personality": "Distant, rebellious past, college-aged",
		"appearance": "College student, somewhat aloof",
		"background": "Your older brother who went through a rebellious phase in high school. He's now in college trying to turn his life around, but still carries the weight of his past mistakes.",
		"current_state": "Balancing college life with family responsibilities, trying to prove he's changed while dealing with lingering guilt and trust issues.",
		"sanity_thresholds": {
			"low": 25.0,      # Below this: withdrawn, suspicious
			"medium": 55.0,   # Normal behavior
			"high": 75.0      # Above this: more open, helpful
		},
		"dialogue_variants": {
			"low_sanity": {
				"greeting": "Yeah?",
				"casual": "Whatever.",
				"intense_topic": "I don't want to talk about that."
			},
			"medium_sanity": {
				"greeting": "Hey.",
				"casual": "What's going on?",
				"intense_topic": "I'm not really comfortable with that topic."
			},
			"high_sanity": {
				"greeting": "Hey! Good to see you.",
				"casual": "How's it going?",
				"intense_topic": "That's a heavy topic, but I'm here if you need to talk."
			}
		}
	},
	
	"mother": {
		"name": "Mysterious Mother",
		"personality": "Stay-at-home mom, mysterious past",
		"appearance": "Motherly but with hidden depths",
		"background": "Your mother who seems to have a mysterious past she won't discuss. She's protective of the family but sometimes acts strangely, especially when certain topics come up.",
		"current_state": "Maintaining the facade of a normal family life while hiding secrets that could change everything you know about your family.",
		"sanity_thresholds": {
			"low": 20.0,      # Below this: paranoid, hiding things
			"medium": 50.0,   # Normal behavior
			"high": 70.0      # Above this: more open about past
		},
		"dialogue_variants": {
			"low_sanity": {
				"greeting": "Oh, it's you...",
				"casual": "I need to check something.",
				"intense_topic": "I don't know what you're talking about."
			},
			"medium_sanity": {
				"greeting": "Hello dear.",
				"casual": "How was your day?",
				"intense_topic": "That's not something I like to discuss."
			},
			"high_sanity": {
				"greeting": "Welcome home!",
				"casual": "Tell me about your day!",
				"intense_topic": "I suppose I could tell you a little about my past..."
			}
		},
		"sanity_actions": {
			"low": "Hides weapons more carefully, becomes paranoid",
			"medium": "Normal behavior",
			"high": "More open about mysterious past"
		}
	},
	
	"father": {
		"name": "Family Man Father",
		"personality": "Family man, likes beer and sports, works on farm",
		"appearance": "Tired but enthusiastic about sports",
		"background": "Your father who works hard on the family farm. He's a traditional family man who loves sports and tries to keep the family together, but he's often too tired to notice the growing tensions.",
		"current_state": "Working long hours on the farm while trying to maintain normalcy, unaware of the dark secrets that are beginning to surface in his family.",
		"sanity_thresholds": {
			"low": 35.0,      # Below this: irritable, suspicious
			"medium": 65.0,   # Normal behavior
			"high": 85.0      # Above this: very supportive, open
		},
		"dialogue_variants": {
			"low_sanity": {
				"greeting": "What now?",
				"casual": "I'm tired.",
				"intense_topic": "I don't want to hear about that."
			},
			"medium_sanity": {
				"greeting": "Hey there.",
				"casual": "How was work?",
				"intense_topic": "That's not really my thing."
			},
			"high_sanity": {
				"greeting": "Welcome home, sport!",
				"casual": "Want to watch the game?",
				"intense_topic": "I'm here for you, no matter what."
			}
		}
	},
	
	"shopkeeper": {
		"name": "Mysterious Shopkeeper",
		"personality": "Enigmatic, knows more than they let on",
		"appearance": "Shadowy figure behind the counter",
		"background": "A mysterious figure who runs the local shop. They seem to know more about the town's dark history than anyone else, and may have connections to the supernatural elements affecting your family.",
		"current_state": "Watching and waiting, offering cryptic advice and dangerous knowledge to those who seek it, while maintaining an air of mystery about their true nature.",
		"sanity_thresholds": {
			"low": 15.0,      # Below this: reveals dark secrets
			"medium": 45.0,   # Normal behavior
			"high": 75.0      # Above this: helpful but mysterious
		},
		"dialogue_variants": {
			"low_sanity": {
				"greeting": "Ah, you've finally seen the truth...",
				"casual": "The shadows whisper your name.",
				"intense_topic": "You're ready to know what lies beneath."
			},
			"medium_sanity": {
				"greeting": "Welcome to my shop.",
				"casual": "Looking for something specific?",
				"intense_topic": "Some things are better left unknown."
			},
			"high_sanity": {
				"greeting": "A customer with clear eyes!",
				"casual": "How may I help you today?",
				"intense_topic": "Knowledge comes at a price, but wisdom is free."
			}
		}
	}
}

# Character relationship states
var character_relationships: Dictionary = {}
var character_sanity_levels: Dictionary = {}

# Character locations and isolation tracking
var character_locations: Dictionary = {}
var nearby_characters: Dictionary = {}

# Sanity-based story paths
var sanity_paths: Dictionary = {
	"low_sanity": {
		"unlocked_topics": ["drugs", "illegal_acts", "violence", "dark_secrets"],
		"blocked_topics": ["family_values", "moral_guidance", "positive_outlook"],
		"character_actions": {
			"mother": "Hides weapons, becomes paranoid, suspicious of player",
			"brother": "Withdraws completely, may avoid player",
			"daughter": "Becomes aggressive, easily manipulated by others",
			"father": "Irritable, may become confrontational",
			"shopkeeper": "Reveals dark secrets, becomes more ominous and threatening"
		}
	},
	"medium_sanity": {
		"unlocked_topics": ["casual_conversation", "family_matters", "daily_life"],
		"blocked_topics": ["extreme_topics", "deep_secrets"],
		"character_actions": {
			"mother": "Normal behavior, some mystery maintained",
			"brother": "Casual interaction, some distance",
			"daughter": "Normal behavior, some vulnerability",
			"father": "Normal behavior, tired but friendly",
			"shopkeeper": "Normal mysterious behavior, helpful but enigmatic"
		}
	},
	"high_sanity": {
		"unlocked_topics": ["family_values", "moral_guidance", "positive_outlook", "deep_connections"],
		"blocked_topics": ["drugs", "illegal_acts", "violence", "dark_secrets"],
		"character_actions": {
			"mother": "More open about past, trusting of player",
			"brother": "More open, supportive, helpful",
			"daughter": "Confident, protective, strong",
			"father": "Very supportive, enthusiastic, open",
			"shopkeeper": "More benevolent, shares wisdom and helpful knowledge"
		}
	}
}

func _ready():
	_initialize_character_states()

func _initialize_character_states():
	# Initialize all characters with medium sanity
	for character_id in characters.keys():
		character_sanity_levels[character_id] = 50.0
		character_relationships[character_id] = 50.0
		character_locations[character_id] = "unknown"
		nearby_characters[character_id] = []

# Check if player is alone with a specific character
func is_alone_with_character(character_id: String) -> bool:
	if not nearby_characters.has(character_id):
		return false
	
	# Player is alone with this character if no other characters are nearby
	return nearby_characters[character_id].size() == 0

# Update character location and nearby characters
func update_character_location(character_id: String, location: String, nearby: Array = []):
	if characters.has(character_id):
		character_locations[character_id] = location
		nearby_characters[character_id] = nearby

# Get all characters at a specific location
func get_characters_at_location(location: String) -> Array:
	var characters_at_location = []
	for character_id in character_locations.keys():
		if character_locations[character_id] == location:
			characters_at_location.append(character_id)
	return characters_at_location

# Check if combat can be initiated with a character
func can_initiate_combat_with(character_id: String, player_sanity: float) -> Dictionary:
	if not characters.has(character_id):
		return {
			"available": false,
			"reason": "Character not found"
		}
	
	var is_alone = is_alone_with_character(character_id)
	var sanity_check = player_sanity < 3.0
	
	var can_combat = sanity_check and is_alone
	var reason = ""
	
	if not can_combat:
		if not sanity_check:
			reason = "Your sanity is too high for combat. You need to be below 3% sanity."
		elif not is_alone:
			reason = "You can only initiate combat when alone with " + characters[character_id]["name"] + "."
		else:
			reason = "Combat is not available at this time."
	
	return {
		"available": can_combat,
		"reason": reason,
		"character_name": characters[character_id]["name"],
		"required_sanity": 3.0,
		"current_sanity": player_sanity,
		"is_alone": is_alone,
		"location": character_locations.get(character_id, "unknown")
	}

# Get character dialogue with combat option if available
func get_character_dialogue_with_combat(character_id: String, dialogue_type: String, player_sanity: float) -> Dictionary:
	var dialogue = get_character_dialogue(character_id, dialogue_type)
	var combat_status = can_initiate_combat_with(character_id, player_sanity)
	
	return {
		"dialogue": dialogue,
		"combat_available": combat_status.available,
		"combat_reason": combat_status.reason,
		"character_name": combat_status.character_name
	}

func get_character_sanity_level(character_id: String) -> float:
	return character_sanity_levels.get(character_id, 50.0)

func set_character_sanity(character_id: String, new_sanity: float):
	character_sanity_levels[character_id] = clamp(new_sanity, 0.0, 100.0)
	_emit_sanity_changed(character_id)

func get_sanity_category(sanity_level: float) -> String:
	if sanity_level < 30.0:
		return "low_sanity"
	elif sanity_level < 70.0:
		return "medium_sanity"
	else:
		return "high_sanity"

func get_character_dialogue(character_id: String, dialogue_type: String) -> String:
	var character = characters.get(character_id, {})
	if not character.has("dialogue_variants"):
		return "Hello."
	
	var sanity_level = get_character_sanity_level(character_id)
	var sanity_category = get_sanity_category(sanity_level)
	
	var variants = character.dialogue_variants.get(sanity_category, {})
	return variants.get(dialogue_type, "Hello.")

func can_discuss_topic(topic: String) -> bool:
	# Try to get player sanity from various sources
	var player_sanity = 50.0  # Default to medium
	
	# Try to get from GameManager if it exists
	if Engine.has_singleton("GameManager"):
		var game_manager = Engine.get_singleton("GameManager")
		if game_manager.has("sanity_level"):
			player_sanity = game_manager.sanity_level
	
	# Try to get from SanitySystem if it exists
	if Engine.has_singleton("SanitySystem"):
		var sanity_system = Engine.get_singleton("SanitySystem")
		if sanity_system.has("get_current_sanity"):
			player_sanity = sanity_system.get_current_sanity()
	
	var sanity_category = get_sanity_category(player_sanity)
	var sanity_path = sanity_paths.get(sanity_category, {})
	
	var blocked_topics = sanity_path.get("blocked_topics", [])
	return not blocked_topics.has(topic)

func get_character_action(character_id: String) -> String:
	# Try to get player sanity from various sources
	var player_sanity = 50.0  # Default to medium
	
	# Try to get from GameManager if it exists
	if Engine.has_singleton("GameManager"):
		var game_manager = Engine.get_singleton("GameManager")
		if game_manager.has("sanity_level"):
			player_sanity = game_manager.sanity_level
	
	# Try to get from SanitySystem if it exists
	if Engine.has_singleton("SanitySystem"):
		var sanity_system = Engine.get_singleton("SanitySystem")
		if sanity_system.has("get_current_sanity"):
			player_sanity = sanity_system.get_current_sanity()
	
	var sanity_category = get_sanity_category(player_sanity)
	var sanity_path = sanity_paths.get(sanity_category, {})
	
	var character_actions = sanity_path.get("character_actions", {})
	return character_actions.get(character_id, "Normal behavior")

func get_character_relationship(character_id: String) -> float:
	return character_relationships.get(character_id, 50.0)

func modify_relationship(character_id: String, change: float):
	var current = character_relationships.get(character_id, 50.0)
	character_relationships[character_id] = clamp(current + change, 0.0, 100.0)

func get_character_response_to_action(character_id: String, action: String) -> String:
	var _character = characters.get(character_id, {})
	var sanity_level = get_character_sanity_level(character_id)
	var sanity_category = get_sanity_category(sanity_level)
	
	# Character-specific responses based on sanity and action
	match character_id:
		"daughter":
			match action:
				"bully":
					if sanity_category == "low_sanity":
						return "I... I don't know what to do..."
					elif sanity_category == "high_sanity":
						return "You really think you can push me around?"
				"support":
					if sanity_category == "low_sanity":
						return "You... you really mean that?"
					elif sanity_category == "high_sanity":
						return "Thank you! I appreciate that."
		
		"brother":
			match action:
				"confront":
					if sanity_category == "low_sanity":
						return "I don't want to talk about it."
					elif sanity_category == "high_sanity":
						return "I know I've been distant. I'm trying to change."
				"support":
					if sanity_category == "low_sanity":
						return "Why are you being nice to me?"
					elif sanity_category == "high_sanity":
						return "Thanks. I really needed that."
		
		"mother":
			match action:
				"question_past":
					if sanity_category == "low_sanity":
						return "I don't know what you're talking about!"
					elif sanity_category == "high_sanity":
						return "I suppose I could tell you a little..."
				"trust":
					if sanity_category == "low_sanity":
						return "I... I'm not sure I can trust anyone."
					elif sanity_category == "high_sanity":
						return "I trust you completely."
		
		"father":
			match action:
				"confront":
					if sanity_category == "low_sanity":
						return "What are you accusing me of?"
					elif sanity_category == "high_sanity":
						return "I understand your concern. Let's talk."
				"support":
					if sanity_category == "low_sanity":
						return "I don't need your help."
					elif sanity_category == "high_sanity":
						return "That means a lot to me, thank you."
		
		"shopkeeper":
			match action:
				"respect":
					if sanity_category == "low_sanity":
						return "Your politeness amuses me... for now."
					elif sanity_category == "high_sanity":
						return "A respectful customer. How refreshing."
				"curiosity":
					if sanity_category == "low_sanity":
						return "Your curiosity will lead you to dark places."
					elif sanity_category == "high_sanity":
						return "Curiosity is a virtue. Let me show you something interesting."
				"direct":
					if sanity_category == "low_sanity":
						return "Directness... I like that. But are you ready for the truth?"
					elif sanity_category == "high_sanity":
						return "Directness is indeed a virtue. What knowledge do you seek?"
	
	return "I don't know how to respond to that."

func _emit_sanity_changed(character_id: String):
	# Emit signal for character sanity change
	character_sanity_changed.emit(character_id, get_character_sanity_level(character_id))

# Signals
signal character_sanity_changed(character_id: String, new_sanity: float)
signal _relationship_changed(character_id: String, new_relationship: float)
