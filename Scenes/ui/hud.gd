extends CanvasLayer 

@onready var health_bar = $Control/HealthBar 
@onready var xp_bar = $Control/XPBar         
@onready var level_label = $Control/LevelLabel 

# Just grab the empty container
@onready var stat_container = $StatContainer 

var player: Player

# We will store our dynamically generated labels here so we can update them later
var stat_labels: Dictionary = {}

func _ready():
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player") as Player
	
	if player:
		player.health_changed.connect(_on_health_changed)
		player.xp_changed.connect(_on_xp_changed)
		player.level_changed.connect(_on_level_changed)
		
		_on_health_changed(player.current_health, player.get_stat("max_health"))
		_on_xp_changed(player.current_xp, player.xp_to_next_level)
		_on_level_changed(player.level)
		
		# --- BUILD THE UI DYNAMICALLY ---
		_generate_stat_labels()

func _generate_stat_labels():
	if player.current_stats.is_empty():
		return
		
	# Loop through every single stat in the player's dictionary!
	for stat_name in player.current_stats.keys():
		# Optional: Skip max_health since we already have a big visual health bar for it
		if stat_name == "max_health":
			continue
			
		var new_label = Label.new()
		stat_container.add_child(new_label)
		
		# Store the label in our HUD dictionary using the stat_name as the key
		stat_labels[stat_name] = new_label

# --- THE LIVE TRACKER ---
func _process(_delta):
	if player and not player.current_stats.is_empty():
		
		# Loop through the labels we generated and update their text
		for stat_name in stat_labels.keys():
			var label = stat_labels[stat_name]
			var value = player.get_stat(stat_name)
			
			# Make it look pretty: change "damage_multiplier" to "Damage Multiplier"
			var display_name = stat_name.replace("_", " ").capitalize()
			
			# Format floats (decimals) and ints (whole numbers) differently
			if value is float:
				label.text = "%s: %.2f" % [display_name, value]
			else:
				label.text = "%s: %d" % [display_name, value]


# --- EXISTING SIGNAL RECEIVERS ---

func _on_health_changed(current_health: float, max_health: float):
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health

func _on_xp_changed(current_xp: int, max_xp: int):
	if xp_bar:
		xp_bar.max_value = max_xp
		xp_bar.value = current_xp

func _on_level_changed(new_level: int):
	if level_label:
		level_label.text = "Level: " + str(new_level)
