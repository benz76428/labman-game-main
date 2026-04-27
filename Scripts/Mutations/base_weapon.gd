class_name BaseWeapon
extends Area2D

@export var projectile_scene: PackedScene
@export var base_damage: float = 1.0
@export var fire_rate: float = 1.0 # Time between shots in seconds

var enemies_in_range: Array[Node2D] = []
var fire_timer: Timer
var player: Player

func _ready():
	# 1. Find the player
	player = get_tree().get_first_node_in_group("player") as Player
	
	# 2. Create the fire rate timer entirely through code (no extra nodes needed!)
	fire_timer = Timer.new()
	fire_timer.wait_time = fire_rate
	fire_timer.autostart = true
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	add_child(fire_timer)
	
	# 3. Connect our Area2D signals to track enemies
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

# --- TARGETING LOGIC ---

func _on_body_entered(body: Node2D):
	if body.is_in_group("enemy"):
		enemies_in_range.append(body)

func _on_body_exited(body: Node2D):
	if enemies_in_range.has(body):
		enemies_in_range.erase(body)

func get_closest_enemy() -> Node2D:
	if enemies_in_range.is_empty(): return null
	
	# Clean up the array in case an enemy died while inside our range
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e) and e.current_health > 0)
	
	var closest_enemy = null
	var closest_distance = INF
	
	for enemy in enemies_in_range:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
			
	return closest_enemy

# --- FIRING LOGIC ---

func _on_fire_timer_timeout():
	var target = get_closest_enemy()
	if target:
		# If we have a target, tell the specific gun to shoot it!
		shoot(target)

# Virtual function: Specific weapons (like gun.gd) will overwrite this!
func shoot(_target: Node2D):
	pass
