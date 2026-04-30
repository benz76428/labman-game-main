extends CharacterBody2D

@export var max_health: int = 3
@export var speed: float = 150.0
@export var attack_range: float = 300.0 # How close they need to be to shoot
@export var fire_rate: float = 1.5 # Time between shots

var current_health: int
var can_shoot: bool = true
const DNA_DROP = preload("res://Scenes/xp/dna_drop.tscn") 
const DAMAGE_NUMBER = preload("res://Scenes/ui/damage_number.tscn")
@onready var player = get_tree().get_first_node_in_group("player")
@export var projectile_scene: PackedScene 

func _ready():
	current_health = max_health

func _physics_process(delta):
	if player:
		var distance_to_player = global_position.distance_to(player.global_position)
		var direction = global_position.direction_to(player.global_position)
		
		if distance_to_player > attack_range:
			velocity = direction * speed
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			if can_shoot:
				shoot(direction)

func shoot(direction: Vector2):
	can_shoot = false
	
	if projectile_scene:
		var proj = projectile_scene.instantiate()
		get_tree().current_scene.add_child(proj)
		proj.global_position = global_position
		proj.rotation = direction.angle()
		
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func take_damage(amount):
	current_health -= amount
	%Slime.play_hurt()
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
