extends Node2D

@export var treasure_room_scene: PackedScene
@export var other_rooms_to_spawn: Array[PackedScene] 

@export var nav_region: NavigationRegion2D
@export_group("Player Spawn Protection")
@export var player_spawn_marker: Marker2D 
@export var safe_zone_size: Vector2 = Vector2(400, 400) 

@export_group("Grid Settings")
# Set this to exactly match your TileMap's tile size! (e.g., 16x16, 32x32)
@export var grid_size: Vector2 = Vector2(16, 16) 

var occupied_areas: Array[Rect2] = []
@onready var spawn_area_polygon = %RoomBoundary
func _ready():
	if spawn_area_polygon:
		spawn_area_polygon.hide()
		
		if player_spawn_marker:
			var safe_pos = player_spawn_marker.global_position - (safe_zone_size / 2.0)
			var safe_rect = Rect2(safe_pos, safe_zone_size)
			occupied_areas.append(safe_rect)
		else:
			push_warning("Player Spawn Marker not assigned!")
			
		# Spawn the treasure room
		if treasure_room_scene:
			spawn_sub_room(treasure_room_scene)
			
		# Spawn all other rooms
		for room_scene in other_rooms_to_spawn:
			if room_scene:
				spawn_sub_room(room_scene)
		
		# --- FIX: BAKE OUTSIDE THE LOOP ---
		# Wait for the physics engine to register all wall colliders
		await get_tree().physics_frame 
		
		if nav_region:
			nav_region.bake_navigation_polygon()
			print("Navigation map baked successfully!")
	else:
		push_error("Please assign a Polygon2D in the inspector!")

# We removed the room_size argument, the script finds it automatically now!
func spawn_sub_room(room_scene: PackedScene):
	# 1. Instantiate the room first so we can look at it
	var room_instance = room_scene.instantiate()
	
	# 2. Look for the ReferenceRect we added
	var bounds_node = room_instance.get_node_or_null("RoomBounds")
	var room_size = Vector2.ZERO
	var global_points = PackedVector2Array()
	for p in spawn_area_polygon.polygon:
		# to_global converts the local point to the actual level position
		global_points.append(spawn_area_polygon.to_global(p))
	# 3. Read the size visually set by the designer!
	if bounds_node and bounds_node is ReferenceRect:
		room_size = bounds_node.size
	else:
		push_warning("Room is missing a ReferenceRect named 'RoomBounds'! Defaulting to 256x256.")
		room_size = Vector2(256, 256)
		
	var max_attempts = 100 
	var attempt = 0
	var spawned = false
	
	var points = spawn_area_polygon.polygon
	var bounds = get_polygon_bounds(points)
	
	while attempt < max_attempts and not spawned:
		# Pick a random spot within the global bounds
		var random_x = randf_range(bounds.position.x, bounds.end.x - room_size.x)
		var random_y = randf_range(bounds.position.y, bounds.end.y - room_size.y)
		var candidate_pos = Vector2(random_x, random_y).snapped(grid_size)
		
		# Define the room corners in Global Space
		var corners = [
			candidate_pos,
			candidate_pos + Vector2(room_size.x, 0),
			candidate_pos + Vector2(0, room_size.y),
			candidate_pos + room_size
		]
		
		# Check corners against the GLOBAL polygon
		var all_corners_inside = true
		for corner in corners:
			if not Geometry2D.is_point_in_polygon(corner, global_points):
				all_corners_inside = false
				break
		
		if all_corners_inside:
			var candidate_rect = Rect2(candidate_pos, room_size)
			var overlaps = false
			for occupied in occupied_areas:
				if candidate_rect.intersects(occupied):
					overlaps = true
					break
			
			if not overlaps:
				# Use global_position for placement
				room_instance.global_position = candidate_pos
				# Use call_deferred to avoid the "busy" parent error
				add_child.call_deferred(room_instance)
				
				occupied_areas.append(candidate_rect)
				spawned = true
				
		attempt += 1
		
	if not spawned:
		room_instance.queue_free()

func get_polygon_bounds(points: PackedVector2Array) -> Rect2:
	if points.is_empty(): return Rect2()
	
	var min_x = points[0].x
	var max_x = points[0].x
	var min_y = points[0].y
	var max_y = points[0].y
	
	for p in points:
		min_x = min(min_x, p.x)
		max_x = max(max_x, p.x)
		min_y = min(min_y, p.y)
		max_y = max(max_y, p.y)
		
	return Rect2(min_x, min_y, max_x - min_x, max_y - min_y)
