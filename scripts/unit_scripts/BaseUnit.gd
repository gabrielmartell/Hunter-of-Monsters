extends CharacterBody3D

class_name BaseUnit

@export var healthbar: Node3D
var healthbar_offset: float

enum OPERATION_MODE {AttackMode, MoveMode, RepairMode, PatrolMode, Other, None}
enum FACTION {Friendly, Hostile, None}
const reached_destination_range = 4

signal unit_dead(thisptr)

# member variables
@export var speed = 5.0
@export var accel = 10.0

@export var rotation_speed = 5

# the repair/attack range
@export var interation_range = 10.0

var current_mode: OPERATION_MODE = OPERATION_MODE.None

@onready var navAgent: NavigationAgent3D = $NavigationAgent3D

# the targets to attack or repair
var attack_target = null
var repair_target = null

@export var hp = 5.0
var hp_max = hp
@export var attack_power = 1.0
@export var repair_power = 1.0

@export var current_faction: FACTION = FACTION.None

const bore_angle = PI / 4

# array of points
@export var patrol_points: Array
var patrol_path_index: int = 0

var moving = false;
var attacking = false;

var selected = false

@export var selection_indicator: Node3D

# end member variables

func _on_repair_target_died(_target):
	repair_target = null
	current_mode = OPERATION_MODE.None
	
func _on_attack_target_died(_target):
	attack_target = null
	current_mode = OPERATION_MODE.None
	
func _reset_state():
	patrol_points.clear()
	patrol_path_index = 0
	current_mode = OPERATION_MODE.None
	attack_target = null
	repair_target = null
	attacking = false
	
func perform_interaction(delta):
	match current_mode:
		OPERATION_MODE.AttackMode:
			attacking = true
			attack_target.on_damage(attack_power * delta)
		OPERATION_MODE.RepairMode:
			repair_target.on_heal(repair_power * delta)


func on_damage(damage_amount):
	hp -= damage_amount
	if hp <= 0:
		unit_dead.emit(self)
		self.queue_free()
		
	
func on_heal(heal_amount):
	hp += heal_amount
	if hp > hp_max:
		hp = hp_max

# this should be called by external code to make the unit move somewhere
func move_to(destination: Vector3):
	_reset_state()
	navAgent.target_position = destination
	current_mode = OPERATION_MODE.MoveMode

func switch_to_idle():
	_reset_state()
	current_mode = OPERATION_MODE.None
	attack_target = null
	repair_target = null
	
func attack(target):
	_reset_state()
	current_mode = OPERATION_MODE.AttackMode
	attack_target = target
	target.unit_dead.connect(_on_attack_target_died)

func repair(target: Node3D):
	_reset_state()
	current_mode = OPERATION_MODE.RepairMode
	repair_target = target
	target.unit_dead.connect(_on_repair_target_died)
	
# use this to set a destination to move to (should probably only be called within 
# the base_unit class)
func _set_destination(destination: Vector3):
	navAgent.target_position = destination

func can_repair():
	return repair_power > 0
	
func can_attack():
	return attack_power > 0
	
# check if we are in range of the selected target
func in_range_of_target():
	if current_mode != OPERATION_MODE.AttackMode and current_mode != OPERATION_MODE.RepairMode:
		return
	
	var target = attack_target if current_mode == OPERATION_MODE.AttackMode else repair_target
	
	return (target.global_position - self.global_position).length() <= interation_range
	

# check if a position is within "viewing bore angle" of the unit
func within_bore_angle_of(point: Vector3):
	var forwards = global_transform.basis.z
	forwards = forwards.normalized()
	var to_position = point - global_position
	to_position = to_position.normalized()
	var angle = acos(forwards.dot(to_position))
	
	return angle < bore_angle

func setup_patrol(points):
	_reset_state()
	patrol_points.clear()
	patrol_path_index = 0
	
	# first append our current pos
	# so patrol will start from the current position and include that point. We may not want this
	patrol_points.append(self.global_position)
	
	for point in points:
		patrol_points.append(point)
		
	current_mode = OPERATION_MODE.PatrolMode

func continue_patrol():
	var num_patrol_points = patrol_points.size()
	if patrol_path_index == num_patrol_points - 1:
		patrol_path_index = 0
		patrol_points.reverse()
	else:
		patrol_path_index += 1
		
func _process_move(delta):
	var final_destination = navAgent.get_final_position()
	
	var in_range = false
	if current_mode == OPERATION_MODE.AttackMode or current_mode == OPERATION_MODE.RepairMode or current_mode == OPERATION_MODE.Other:
		if (final_destination - self.global_position).length() <= interation_range:
			perform_interaction(delta) # repair or attack the target
			in_range = true
	else:
		in_range = false # we have no concept of range if we are just moving somewhere
	
	# we need to get somewhere
	var direction
	if not in_range and (final_destination - self.global_position).length() > reached_destination_range:
		direction = navAgent.get_next_path_position() - global_position
		direction = direction.normalized()
		
		velocity = velocity.lerp(direction * speed, accel * delta)
		moving = true
		
	else:
		velocity = Vector3(0,0,0) # we got somewhere, stop moving
		if current_mode == OPERATION_MODE.PatrolMode:
			moving = true
			continue_patrol()
		moving = false
		
func _process_orient(delta):
	var direction
	# orient towards the next destination / target
	var next_point = navAgent.get_next_path_position()
	direction = next_point - self.global_position
	if direction != Vector3(0, 0, 0):
		direction.y = 0
		direction = direction.normalized()
		var angle = atan2(direction.x, direction.z)
		
		var current_orientation = deg_to_rad(rotation_degrees.y)
		
		var next_orientation = lerp_angle(current_orientation, angle, rotation_speed * delta)
		
		
		rotation_degrees.y = rad_to_deg(next_orientation)		

func _ready():
	if healthbar:
		healthbar_offset = abs(healthbar.global_position.y - self.global_position.y)

func _physics_process(delta):
	attacking = false
	moving = false
	
	
	if healthbar:
		var mat = healthbar.get_surface_override_material(0)
		
		mat.set_shader_parameter("percentage", hp / hp_max)
		
		healthbar.global_position = self.global_position
		healthbar.global_position.y += healthbar_offset
		
		var camera = get_tree().get_root().get_node("./Main/Camera/Camera3D")
		healthbar.look_at(camera.global_position)
		
		
		
	
	# adjust the selected indicator
	if selection_indicator:
		selection_indicator.visible = selected
	
	match current_mode:
		OPERATION_MODE.AttackMode:
			_set_destination(attack_target.global_position)
		OPERATION_MODE.MoveMode:
			pass # position should already be set don't need to change it
		OPERATION_MODE.RepairMode:
			_set_destination(repair_target.global_position)
		OPERATION_MODE.PatrolMode:
			_set_destination(patrol_points[patrol_path_index])
		OPERATION_MODE.Other:
			pass
		OPERATION_MODE.None:
			move_and_slide()
			return # there is nothing to do here
	
	_process_move(delta)
	
	_process_orient(delta)

	move_and_slide()
	
	
