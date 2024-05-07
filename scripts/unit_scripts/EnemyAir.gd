extends "res://scripts/unit_scripts/BaseEnemy.gd"

@onready var anim_tree = $AnimationTree

func _ready():
	speed = 5.0
	if healthbar:
		healthbar_offset = abs(healthbar.global_position.y - self.global_position.y)

func _process(delta):
	nextTarget()
	
	if moving:
		anim_tree["parameters/BlendSpace1D/blend_position"] = 0
	elif attacking:
		anim_tree["parameters/BlendSpace1D/blend_position"] = 1
	else:
		anim_tree["parameters/BlendSpace1D/blend_position"] = 0
		
	#if there is no target, start moving to center
	if attack_target == null:
		noTarget()
		#move_to(center)

func _on_aggro_range_area_entered(area):
	#there is no current target
	if area.owner.is_in_group("buildings"):
		if attack_target == null:	# if there is no current target, set it as the area.owner
			attack(area.owner)
		
		area.owner.unit_dead.connect(removeDeadUnit)
		targets.append(area.owner)	#add to targets array
	#print("Current Target is: " + str(attack_target))
	#print("Targets array: " + str(targets))	

func _on_de_aggro_range_area_exited(area):
	if not area.owner.is_in_group("buildings") and not area.owner.is_in_group("units"):
		return
	if area.owner == attack_target:
		attack_target = null
	targets.remove_at(targets.find(area.owner))
	area.owner.unit_dead.disconnect(removeDeadUnit)
	#print("Current Target is: " + str(attack_target))
	#print("Targets array: " + str(targets))	
		
		
#get next target in targets array. Prioritize units for ground enemy
func nextTarget():
	if targets.size() > 0 && attack_target == null:
		attack(targets[0])
		
		
#remove dead units from targets array
func removeDeadUnit(dead_unit):
	targets.remove_at(targets.find(dead_unit))
	current_mode = OPERATION_MODE.None
	attack_target = null
	nextTarget()
	print("Targets array: " + str(targets))	
	print("Target after death is: " + str(attack_target))

	
