extends Node2D

var enemy_spawn_chances = [
	{
		"scene": preload("res://Scenes/Enemies/Test_Slime/mob.tscn"), 
		"weight": 80.0 #chance
	},
	{
		"scene": preload("res://Scenes/Enemies/Test_fast_slime/fast_mob.tscn"), 
		"weight": 20.0 #chance
	},
	{
		"scene": preload("res://Scenes/Enemies/Fire Slinger/fire_slinger.tscn"), 
		"weight": 20.0 #chance
	}
]
func spawn_mob():
	var enemy_scene_to_spawn = get_random_enemy_scene()
	var new_mob = enemy_scene_to_spawn.instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)
	


func _on_mob_spawner_timeout() -> void:
	spawn_mob()

	
func get_random_enemy_scene() -> PackedScene:
	var total_weight = 0.0
	
	# First, calculate the total weight of all enemies
	for enemy in enemy_spawn_chances:
		total_weight += enemy["weight"]
		
	# Pick a random number between 0 and the total weight
	var random_roll = randf_range(0.0, total_weight)
	
	# Go through the enemies again and see which one the roll landed on
	var current_weight = 0.0
	for enemy in enemy_spawn_chances:
		current_weight += enemy["weight"]
		if random_roll <= current_weight:
			return enemy["scene"]
			
	# Fallback just in case (returns the first enemy)
	return enemy_spawn_chances[0]["scene"]
