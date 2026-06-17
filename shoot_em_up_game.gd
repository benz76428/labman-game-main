extends Node2D



var enemy_spawn_chances = [
	#{
		#"scene": preload("res://Scenes/Enemies/Test_Slime/mob.tscn"), 
		#"weight": 80.0 #chance
	#},
	{
		"scene": preload("res://Scenes/Enemies/The Slime/the_slime.tscn"), 
		"weight": 20.0 #chance
	},
	{
		"scene": preload("res://Scenes/Enemies/Fire Slinger/fire_slinger.tscn"), 
		"weight": 20.0 #chance
	}
]
func spawn_mob():
	var spawn_pos = get_valid_vs_spawn()
	if spawn_pos != Vector2.INF:
		var enemy_scene_to_spawn = get_random_enemy_scene()
		var new_mob = enemy_scene_to_spawn.instantiate()
		new_mob.global_position = spawn_pos
		add_child(new_mob)
	
func get_valid_vs_spawn() -> Vector2:
	var spawn_boundary = get_tree().get_first_node_in_group("spawn_boundary")
	
	if not spawn_boundary:
		push_error("Could not find the 'spawn_boundary' group!")
		return Vector2.INF
		
	var lab_bounds = spawn_boundary.polygon
	
	for i in range(20):
		%PathFollow2D.progress_ratio = randf()
		var test_pos = %PathFollow2D.global_position
		
		# --- THE FIX IS HERE ---
		# Convert the global test position into the Polygon's local coordinates
		var local_test_pos = spawn_boundary.to_local(test_pos)
		
		# Now check if the LOCAL point is inside the LOCAL polygon
		if Geometry2D.is_point_in_polygon(local_test_pos, lab_bounds):
			return test_pos # We still return the global pos so they spawn in the right place!
			
	return Vector2.INF

func _on_mob_spawner_timeout() -> void:
	spawn_mob()

	
func get_random_enemy_scene() -> PackedScene:
	var total_weight = 0.0
	
	
	for enemy in enemy_spawn_chances:
		total_weight += enemy["weight"]
		
	
	var random_roll = randf_range(0.0, total_weight)
	
	
	var current_weight = 0.0
	for enemy in enemy_spawn_chances:
		current_weight += enemy["weight"]
		if random_roll <= current_weight:
			return enemy["scene"]
			
	
	return enemy_spawn_chances[0]["scene"]
