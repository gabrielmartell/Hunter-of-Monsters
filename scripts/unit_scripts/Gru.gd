extends "res://scripts/unit_scripts/BaseUnit.gd"

class_name gru

enum GRU_ACTIVITY {Building, Harvesting, None}

@onready var anim_tree = $AnimationTree

var harvest_target = null
var harvest_time = 0
var harvest_wait_time = 2.0
var building
var buildLocation = Vector3(0, 0, 0)
var buildTimer = 0

var boneCost = 0
var foodCost = 0
var oreCost = 0

var activity: GRU_ACTIVITY = GRU_ACTIVITY.None

var building_time = {
	"Base": 5,
	"TCamp": 5,
	"Trap": 2
}

# Called when the node enters the scene tree for the first time.
func _ready():
	current_faction = FACTION.Friendly
	
	if healthbar:
		healthbar_offset = abs(healthbar.global_position.y - self.global_position.y)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y = 0.321717
	
	if moving:
		anim_tree["parameters/BlendSpace1D/blend_position"] = 1
	elif attacking == true:
		anim_tree["parameters/BlendSpace1D/blend_position"] = 3
	else:
		anim_tree["parameters/BlendSpace1D/blend_position"] = 0
			
	if activity != GRU_ACTIVITY.Harvesting:
		harvest_target = null
		
	if (activity == GRU_ACTIVITY.Building):
		#build when at location
		if (global_position - buildLocation).length() <= interation_range:
			# stop moving
			anim_tree["parameters/BlendSpace1D/blend_position"] = 2
			move_to(global_position)
			activity = GRU_ACTIVITY.Building
			buildTimer -= delta
			if buildTimer <= 0:
				Player.setFood(Player.getFood()-foodCost)
				Player.setBones(Player.getBones()-boneCost)
				Player.setOre(Player.getOre()-oreCost)
				foodCost = 0
				oreCost = 0
				boneCost = 0
				var b = building.instantiate()
				b.position = buildLocation	#set building location to the selected location
				get_tree().get_root().get_node("./Main/World/NavigationRegion3D").add_child_update_navigation(b)
				b.add_to_group("buildings")
		
				#move GRU out of the building's interior. Might be better to base off individual node size
				position = (Vector3(position.x, 0.321717, position.z + 10))
				activity = GRU_ACTIVITY.None
				current_mode = OPERATION_MODE.None
		
	var Player = get_node("/root/Player")
	if (activity == GRU_ACTIVITY.Harvesting):
		# this should be done differently by moving the enum to a shared file we can import
		if((global_position - harvest_target.global_position).length() <= interation_range):
			if moving == false:
				anim_tree["parameters/BlendSpace1D/blend_position"] = 2
			else:
				anim_tree["parameters/BlendSpace1D/blend_position"] = 1
			harvest_time += delta
			if(harvest_time > harvest_wait_time):
				harvest_time = 0
				if (harvest_target.resourceType == Harvestable.ResourceType.Ore):
					Player.setOre(Player.getOre()+1)
					print(Player.getOre())
				if (harvest_target.resourceType == Harvestable.ResourceType.Food):
					Player.setFood(Player.getFood()+1)
				if (harvest_target.resourceType == Harvestable.ResourceType.Bones):
					Player.setBones(Player.getBones()+1)

func harvest(target):
	print("Harvesting")
	anim_tree["parameters/BlendSpace1D/blend_position"] = 1
	
	current_mode = OPERATION_MODE.Other
	activity = GRU_ACTIVITY.Harvesting
	
	harvest_target = target
	
	navAgent.target_position = target.global_position

func buildBase(location):
	var Player = get_node("/root/Player")
	foodCost = 7
	boneCost = 5
	if(Player.getFood() >= 7 and Player.getBones() >= 5):
		buildLocation = location
		activity = GRU_ACTIVITY.Building
		move_to(location)
		current_mode = OPERATION_MODE.Other
		building = load("res://src/base.tscn")
		buildTimer = building_time["Base"]
		
	else:
		print("Not enough for cost!")
	
func buildCamp(location):
	var Player = get_node("/root/Player")
	boneCost = 2
	oreCost = 7
	if(Player.getBones() >= 2 and Player.getOre() >= 7):
		buildLocation = location
		activity = GRU_ACTIVITY.Building
		move_to(location)
		current_mode = OPERATION_MODE.Other
		building = load("res://src/TrainingCamp.tscn")
		buildTimer = building_time["TCamp"]
	else:
		print("Not enough for cost!")
	
func buildTrap(location):
	var Player = get_node("/root/Player")
	oreCost = 5
	foodCost = 2
	print(Player.getFood())
	print(Player.getOre())
	if(Player.getOre() >= 5 and Player.getFood() >= 2):
		buildLocation = location
		activity = GRU_ACTIVITY.Building
		move_to(location)
		current_mode = OPERATION_MODE.Other
		building = load("res://src/trap.tscn")
		buildTimer = building_time["Trap"]
	else:
		print("Not enough for cost!")
