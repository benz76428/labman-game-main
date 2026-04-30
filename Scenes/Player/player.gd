class_name Player
extends CharacterBody2D

# --- SIGNALS ---
signal xp_changed(current_xp, max_xp)
signal level_changed(new_level)
signal health_changed(current_health, max_health)
signal stats_updated
# Preload your mutation picker scene
const MUTATION_PICKER_SCENE = preload("res://Scenes/Mutation Picker/mutation_picker.tscn")

# --- THE NEW STAT DICTIONARY ---
@export var base_stats: Dictionary = {
	"max_health": 100.0,
	"speed": 300.0,
	"speed_multiplier": 1.0,
	"damage_multiplier": 1.0,           
	"pickup_radius": 50.0,     
	"crit_chance": 0.0
}

# The dictionary that actually changes during gameplay
var current_stats: Dictionary 

var player_direction: Vector2 = Vector2.DOWN
# --- PROGRESSION & HEALTH VARIABLES ---
var current_health: float
var level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 5 # How much DNA you need to hit Level 2

var weapon
var is_attacking: bool = false
func _ready():
	# 1. Copy the base stats to our active stats on spawn
	current_stats = base_stats.duplicate()
	
	# 2. Set our health using the dictionary stat and update the UI
	current_health = get_stat("max_health")
	health_changed.emit(current_health, get_stat("max_health"))

# ---------------------------------------------------------
# NEW DICTIONARY FUNCTIONS
# ---------------------------------------------------------

# Mutations call this to easily upgrade any stat
func modify_stat(stat_name: String, amount: float):
	if current_stats.has(stat_name):
		current_stats[stat_name] += amount
		print(stat_name, " increased by ", amount, ". New total: ", current_stats[stat_name])
		stats_updated.emit() # <--- THIS IS CRITICAL FOR THE HUD
	else:
		print("ERROR: Tried to upgrade a stat that doesn't exist: ", stat_name)
func get_stat(stat_name: String) -> float:
	if current_stats.has(stat_name):
		return current_stats[stat_name]
	return 0.0

# ---------------------------------------------------------
# EXISTING COMBAT & PROGRESSION LOGIC
# ---------------------------------------------------------

func take_damage(amount: int):
	current_health -= amount
	health_changed.emit(current_health, get_stat("max_health"))
	print("Player took damage! Health: ", current_health)
	
	if current_health <= 0:
		die()

func die():
	print("Player Died!")
	get_tree().change_scene_to_file("res://Main Menu/main_menu.tscn")

# Enemies call this when they die and drop DNA
func gain_xp(amount: int):
	current_xp += amount
	xp_changed.emit(current_xp, xp_to_next_level)
	
	if current_xp >= xp_to_next_level:
		level_up()

func level_up():
	# Subtract the required XP, keep the overflow
	current_xp -= xp_to_next_level
	level += 1
	
	# Increase the XP needed for the next level (e.g., multiply by 1.5)
	xp_to_next_level = int(xp_to_next_level * 1.5) 
	
	# Update the UI
	level_changed.emit(level)
	xp_changed.emit(current_xp, xp_to_next_level)
	
	# Spawn the mutation picker and pause the game!
	if MUTATION_PICKER_SCENE:
		var mutation_picker = MUTATION_PICKER_SCENE.instantiate()
		get_tree().root.add_child(mutation_picker)
		get_tree().paused = true
