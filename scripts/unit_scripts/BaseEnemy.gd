extends BaseUnit

# Enemy Class
# 3 rules
# 1. Seek player units/buildings
# 2. Attack if in range
# 3. Prioritize units over buildings
# bonus. Air monster only attacks buildings

#center = 12,0,-1

#var curTarget = null	
var center = Vector3(0, 0, -1)	#position that all enemies will head towards.
var startPos
var targets = []

func _ready():
	startPos = self.global_position
	current_faction = FACTION.Hostile

func _process(delta):
	#below should be in individual enemy code
	# if target is not set,		(Make this search function)
		#check for targets in range   Radial check is fine
			#if there is target, make sure it is a friendly, not a hostile
				# check if building or unit. if unit is about same distance, prioritize unit
					#set and attack target.
					
	# target is set, then check if still in attack range
		# if in attack range, 
			#attack target
		# not in attack range,
			#look for new target using Search function
	
	#no target in range, move towards center a little bit
	#if attack_target != null:
	#	move_to(center)
	pass
	
#remove dead units from targets array
func removeDeadUnit(dead_unit):	
	targets.remove_at(targets.find(dead_unit))
	current_mode = OPERATION_MODE.None
	attack_target = null
	print("Targets array: " + str(targets))	
	print("Target after death is: " + str(attack_target))


#loop through all buildings and target closest one
func noTarget():
	var closestTar
	var buildings = get_tree().get_nodes_in_group("buildings")	#array of all buildings
	var closestDist = 999999
	for i in buildings:	
		var distance = i.position.distance_to(self.position)
		if distance < closestDist:
			closestDist = distance
			closestTar = i

	if closestTar:			
		closestTar.unit_dead.connect(removeDeadUnit)
		targets.append(closestTar)
