extends CanvasLayer

signal mutation_selected(mutation_name)

@onready var container: HBoxContainer = %HBoxContainer 

# mutation picker inspector
@export var possible_mutations: Array[Mutation]

# --- NEW: We must tell the script to run when it spawns! ---
func _ready():
	# Make sure this UI can run while the game is paused!
	process_mode = Node.PROCESS_MODE_ALWAYS 
	generate_choices()

func generate_choices() -> void:
	if not is_inside_tree(): await ready
	
	for child in container.get_children():
		child.queue_free()
		
	if possible_mutations.is_empty():
		print("ERROR: No mutations assigned in the inspector!")
		return
		
	var available = possible_mutations.duplicate()
	
	# Optional: Filter out mutations that are already at max level
	available = available.filter(func(mut): return mut.current_level < mut.max_level)
	
	available.shuffle()
	
	var num_choices = min(3, available.size())
	
	for i in range(num_choices):
		var mutation_data = available[i]
		var btn = Button.new()
		
		# Set the text and size (Using the correct variable name!)
		btn.text = mutation_data.mutation_name + "\n\n" + mutation_data.mutation_description
		btn.custom_minimum_size = Vector2(200, 300)
		
		# Connect the button click to our function, passing the specific mutation
		btn.pressed.connect(_on_button_pressed.bind(mutation_data))
		
		# Add the button to your UI container
		container.add_child(btn)

func _on_button_pressed(mutation_data: Mutation) -> void:
	# Find the player in the scene
	var player = get_tree().get_first_node_in_group("player") 
	if player:
		# Use our new universal apply method!
		mutation_data.apply_mutation(player)
		
	# Unpause the game and destroy the picker
	get_tree().paused = false
	queue_free()
