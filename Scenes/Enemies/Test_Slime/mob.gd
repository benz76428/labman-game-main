extends CharacterBody2D

@export var max_health: int = 10
@export var speed: float = 50 
@export var damage_amount: int = 10
@export var attack_cooldown: float = 1.0
@export var animated_sprite_2d: AnimatedSprite2D
var can_attack: bool = true
var current_health: int
var flash_tween: Tween
var anim_name = "walk_right"
const DNA_DROP = preload("res://Scenes/xp/dna_drop.tscn") 
const DAMAGE_NUMBER = preload("res://Scenes/ui/damage_number.tscn")
@onready var player = get_tree().get_first_node_in_group("player")
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var sprite = $AnimatedSprite2D 
func _ready():
	
	animated_sprite_2d.play('walk_right')
	current_health = max_health
	if animated_sprite_2d.material:
		animated_sprite_2d.material = animated_sprite_2d.material.duplicate()
	if nav_agent:
		nav_agent.path_desired_distance = 10.0
		nav_agent.target_desired_distance = 20.0
func _physics_process(delta: float) -> void:
	if player == null:
		return
	# Tell the agent where the player currently is
	nav_agent.target_position = player.global_position
	var distance_to_player = global_position.distance_to(player.global_position)
	# If we are close enough to the player, stop walking
	if distance_to_player < 20.0:
		# We are actually touching the player. Stop moving.
		velocity = Vector2.ZERO
	elif nav_agent.is_navigation_finished() or not nav_agent.is_target_reachable():
		# The path is broken, or the map is still loading! 
		# FALLBACK: Walk directly toward the player like the old code.
		var fallback_direction = global_position.direction_to(player.global_position)
		velocity = fallback_direction * speed
	else:
		# The path is perfect! Follow the smart path around the walls.
		var next_path_pos = nav_agent.get_next_path_position()
		var direction = global_position.direction_to(next_path_pos)
		velocity = direction * speed
	
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# mob attack cooldown
		if collider is Player and can_attack:
			collider.take_damage(damage_amount)
			trigger_attack_cooldown()
			
func trigger_attack_cooldown() -> void:
	can_attack = false
	if get_tree() == null:
		return
	await get_tree().create_timer(attack_cooldown).timeout
	
	can_attack = true
	
func take_damage(amount:float):
	current_health -= amount
	#%Slime.play_hurt()
	sprite.material.set_shader_parameter("flash_modifier", 1.0)
	await get_tree().create_timer(0.05).timeout
	sprite.material.set_shader_parameter("flash_modifier", 0.0)
	var dmg_indicator = DAMAGE_NUMBER.instantiate()
	# Add it to the main scene tree so it doesn't get deleted if the mob dies
	get_tree().current_scene.add_child(dmg_indicator)
	# Cast the amount to an int and trigger the popup animation
	dmg_indicator.popup(int(amount), global_position)
	
	if current_health <= 0:

		$Hitbox.set_deferred("disabled", true)

		call_deferred("_on_death")

func _on_death():
	# 1. Instantiate and setup the DNA drop
	var drop = DNA_DROP.instantiate()
	drop.global_position = global_position
	
	# 2. Instantiate and setup the smoke
	# const SMOKE_SCENE = preload("res://Test Assets/smoke_explosion/smoke_explosion.tscn")
	#var smoke = SMOKE_SCENE.instantiate()
	#smoke.global_position = global_position
	
	# 3. Add them to the room
	var room = get_parent()
	room.add_child(drop)
	#room.add_child(smoke)
	
	# 4. Finally, remove the enemy
	queue_free()
	

func _on_hitbox_body_entered(body: Node2D) -> void:
	# Check if the thing is the player
	if body == player:

		if body.has_method("take_damage"):
			body.take_damage(10)
