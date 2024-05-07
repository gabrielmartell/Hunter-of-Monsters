extends "res://scripts/building_scripts/BuildingGeneral.gd"


#preload required units
var gruUnit = preload("res://models/Unit Models/gru.tscn")

#define training time for units available to train. 
var training_time = {
	"GRU": 5
}
var training_cost = Vector3(0, 5, 2)

var spawnPosition = Vector3(10, 0, 0) #Default Spawn location. Implement way to change that for final version

func _ready():
	current_faction = FACTION.Friendly
	#current_faction = 0
	if healthbar:
		healthbar_offset = abs(healthbar.global_position.y - self.global_position.y)

# Inputs
func _input(event):
	if destroyed == false:
		if Input.is_action_just_pressed("gru"):
			print("g pressed")
			train_unit("GRU")

# Train unit.  Adds unit to queue
func train_unit(unit_type):
	var Player = get_node("/root/Player")
	if(Player.getBones() >= training_cost.z and Player.getOre() >= training_cost.x and Player.getFood() >= training_cost.y):
		Player.setBones(Player.getBones() - training_cost.z)
		Player.setFood(Player.getFood() - training_cost.y)
		Player.setOre(Player.getOre() - training_cost.x)
		if queue.size() < max_queue_size:
			queue.append(unit_type)
			if queue.size() == 1:
				queue_timer = training_time[unit_type]
	else:
		print("Not enough for cost!")

# Process queue
func _process(delta):
	#if hp > 0:
	#	takeDamage(0.1)
	#	print(hp)
	
	if healthbar:
		var mat = healthbar.get_surface_override_material(0)
		
		mat.set_shader_parameter("percentage", hp / hp_max)
		
		healthbar.global_position = self.global_position
		healthbar.global_position.y += healthbar_offset
	
	#if building is not destroyed and if queue is not empty
	if destroyed == false:
		if queue.size() > 0:
			queue_timer -= delta
		
			#when timer runs down
			if queue_timer <= 0:
				spawn_unit(queue[0])
				queue.remove_at(0)
				#if queue is not empty, set timer to next unit's training time.
				if queue.size() > 0:
					queue_timer = training_time[queue[0]]
				else:
					queue_timer = 0

# Spawn unit
func spawn_unit(unit_type):
	var unit
	if unit_type == "GRU":
		unit = gruUnit.instantiate()
		unit.add_to_group("units")
	#places unit at spawnlocation. Should change to walk to spawn location for final version
	unit.position = global_position + spawnPosition # Adjust spawn position as needed
	unit.scale = Vector3(1.332,1.332,1.332)
			
	get_tree().get_root().get_node("./Main/PlayerUnits").add_child(unit)
	
