extends CharacterBody2D

@export var speed: float = 100.0

func _get_game_manager():
	# Get GameManager from Global autoload
	if Engine.has_singleton("Global"):
		var global = Engine.get_singleton("Global")
		return global.get_game_manager()
	return null
@export var interaction_range: float = 50.0

# References
@onready var sprite: CanvasItem = $Sprite2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# State
var is_interacting: bool = false
var nearby_interactables: Array = []

func _ready():
	# Connect interaction signals
	interaction_area.body_entered.connect(_on_interaction_area_entered)
	interaction_area.body_exited.connect(_on_interaction_area_exited)

func _physics_process(delta):
	var game_manager = _get_game_manager()
	if not game_manager or game_manager.current_state != game_manager.GameState.PLAYING:
		return
	
	_handle_movement()
	_handle_interaction()

func _handle_movement():
	var input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	
	input_vector = input_vector.normalized()
	velocity = input_vector * speed
	
	move_and_slide()
	
	# Update animation based on movement
	if input_vector != Vector2.ZERO:
		_play_movement_animation(input_vector)
	else:
		_play_idle_animation()

func _handle_interaction():
	if Input.is_action_just_pressed("interact") and nearby_interactables.size() > 0:
		var closest = _get_closest_interactable()
		if closest:
			closest.interact(self)

func _on_interaction_area_entered(body):
	if body.has_method("interact"):
		nearby_interactables.append(body)

func _on_interaction_area_exited(body):
	if body in nearby_interactables:
		nearby_interactables.erase(body)

func _get_closest_interactable():
	if nearby_interactables.size() == 0:
		return null
	
	var closest = nearby_interactables[0]
	var closest_distance = global_position.distance_to(closest.global_position)
	
	for interactable in nearby_interactables:
		var distance = global_position.distance_to(interactable.global_position)
		if distance < closest_distance:
			closest = interactable
			closest_distance = distance
	
	return closest

func _play_movement_animation(direction: Vector2):
	# Simple animation based on direction
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			animation_player.play("walk_right")
		else:
			animation_player.play("walk_left")
	else:
		if direction.y > 0:
			animation_player.play("walk_down")
		else:
			animation_player.play("walk_up")

func _play_idle_animation():
	animation_player.play("idle")

func switch_world():
	# Visual effect for world switching
	var tween = create_tween()
	tween.tween_property(sprite, "color", Color(0.5, 0.5, 1.0, 0.8), 0.3)
	tween.tween_property(sprite, "color", Color.WHITE, 0.3)
	
	# Switch world in game manager
	var game_manager = _get_game_manager()
	if game_manager:
		game_manager.switch_world()

func take_damage(amount: int):
	# Visual feedback for taking damage
	var tween = create_tween()
	tween.tween_property(sprite, "color", Color.RED, 0.1)
	tween.tween_property(sprite, "color", Color.WHITE, 0.1)
	
	# Reduce sanity
	var game_manager = _get_game_manager()
	if game_manager:
		game_manager.change_sanity(-amount * 2.0)

func get_interaction_prompt() -> String:
	if nearby_interactables.size() > 0:
		var closest = _get_closest_interactable()
		if closest and closest.has_method("get_interaction_text"):
			return closest.get_interaction_text()
	return ""

func _input(event):
	if event.is_action_pressed("world_switch"):
		switch_world()
	elif event.is_action_pressed("pause"):
		var game_manager = _get_game_manager()
		if game_manager:
			game_manager.current_state = game_manager.GameState.PAUSED
			game_manager.game_state_changed.emit(game_manager.current_state) 
