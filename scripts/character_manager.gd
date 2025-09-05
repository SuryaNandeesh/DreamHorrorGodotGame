extends Node

# Character manager for handling character interactions in the visual novel
# This is an autoload singleton, do not use class_name

# Character definitions with personalities and dialogue
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

# Character locations
var character_locations: Dictionary = {}

# Character dialogue paths
var dialogue_paths: Dictionary = {
	"casual": {
		"mother": ["How was your day?", "Would you like something to eat?", "The weather is nice today."],
		"brother": ["Hey, what's up?", "Want to hang out?", "Been busy with college stuff."],
		"daughter": ["Hey there!", "What's new?", "Want to talk?"],
		"father": ["How's it going, sport?", "Want to watch the game?", "Been working hard on the farm."],
		"shopkeeper": ["Welcome!", "Looking for anything specific?", "Let me know if you need help."]
	},
	"personal": {
		"mother": ["I worry about you sometimes.", "The family means everything to me.", "We should spend more time together."],
		"brother": ["College is tough but I'm managing.", "Sorry I've been distant.", "Things are getting better."],
		"daughter": ["I'm trying my best.", "Thanks for being there.", "It's not easy, you know?"],
		"father": ["Proud of this family.", "Working hard to provide.", "Always here if you need me."],
		"shopkeeper": ["This town has many stories.", "Been here a long time.", "Seen many things change."]
	}
}

func _ready():
	_initialize_character_states()

func _initialize_character_states():
	# Initialize all characters
	for character_id in characters.keys():
		character_locations[character_id] = "unknown"

# Update character location
func update_character_location(character_id: String, location: String):
	if characters.has(character_id):
		character_locations[character_id] = location

# Get all characters at a specific location
func get_characters_at_location(location: String) -> Array:
	var characters_at_location = []
	for character_id in character_locations.keys():
		if character_locations[character_id] == location:
			characters_at_location.append(character_id)
	return characters_at_location



func get_character_dialogue(character_id: String, dialogue_type: String) -> String:
	if not dialogue_paths.has(dialogue_type) or not dialogue_paths[dialogue_type].has(character_id):
		return "Hello."
	
	var dialogues = dialogue_paths[dialogue_type][character_id]
	return dialogues[randi() % dialogues.size()]

func get_character_name(character_id: String) -> String:
	return characters.get(character_id, {}).get("name", "Unknown")

func get_character_description(character_id: String) -> String:
	var character = characters.get(character_id, {})
	return character.get("background", "No description available.")
