extends Camera3D

const MOVE_MARGIN = 20
const MOVE_SPEED = 30

# Building Hovering Variables
var building
var building_hologram
var building_type = -1 #0 For Base, 1 For Camp, 2 For Trap
var building_selected = false
var building_holo_active = false
var building_confirmed = false

@onready var selection_box = $DragBox

var boxStart = Vector2();

var selected = []
var patrolPoints = []

var buildingPatrol = false

var ray_length = 1000

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	for unit in selected:
		unit.selected = true
	
	var m_pos = get_viewport().get_mouse_position()
	calc_move(m_pos, delta)
	
	# If a keybind was pressed (B,T or C), load the Hologram and add it to the Hologram folder.
	if building_selected == true and building_holo_active == false:
		#print("Creating Holo")
		building_hologram = building.instantiate()
		get_tree().get_root().get_node("./Main/Hologram").add_child(building_hologram)
		building_holo_active = true
	
	# After loading and creating the hologram, move it with the mouse.
	if building_selected == true and building_holo_active == true:
		var clickTarget = raycastToMouse(m_pos)
		#print(clickTarget.position)
		if clickTarget.is_empty():
			pass
		else:
			building_hologram.position = clickTarget.position
			building_hologram.position.y = 0.3
			
			
	if Input.is_action_just_pressed("click"):
		selection_box.start_sel_pos = m_pos
		boxStart = m_pos
		for unit in selected:
			unit.selected = false
		disconnect_signals()
		selected = []
		patrolPoints = []
		print(Player.getBones())
	if Input.is_action_pressed("click"):
		selection_box.m_pos = m_pos
		selection_box.is_visible = true
	if Input.is_action_just_released("click"):
		selection_box.is_visible = false
		select_units(m_pos)
		
	if Input.is_action_just_pressed("esc"):
		get_tree().quit()

			
	if Input.is_action_just_pressed("rclick"):
		# Leave the building GUI
		if (building_selected):
			building_confirmed = false
			building_holo_active = false
			building_selected = false
			building_type = -1
			get_tree().get_root().get_node("./Main/Hologram/Building").queue_free()
						
		var clickTarget = raycastToMouse(m_pos)
		if(!selected.is_empty()):
			if(clickTarget.collider.is_in_group("units") or clickTarget.collider.is_in_group("enemyUnits")):
				for unit in selected:
					if not unit.is_in_group("units"):
						continue
					if unit.current_faction == clickTarget.collider.current_faction:
						print("REPAIR")
						unit.repair(clickTarget.collider)
					else:
						print("ATTACK")
						unit.attack(clickTarget.collider)
						
			elif (clickTarget.collider.is_in_group("resource")):
				for unit in selected:
					if unit.is_in_group("gru"):
						unit.harvest(clickTarget.collider)
			elif (clickTarget.collider.is_in_group("buildings")):
				for unit in selected:
					if unit.is_in_group("gru"):
						print("REPAIR")
						unit.repair(clickTarget.collider)
			else:
				if buildingPatrol:
					patrolPoints.append(clickTarget.position)
					return
				for unit in selected:
					if unit is CharacterBody3D:
						if not unit.is_in_group("units"):
							continue
						unit.move_to(clickTarget.position)
					else:
						if not unit.is_in_group("units"):
							continue
						unit.get_child(0).move_to(clickTarget.position)
						
					
	if Input.is_action_just_pressed("buildBase"):
		var clickTarget = raycastToMouse(m_pos)
		
		# If no building is selected currently, select this building
		if (building_selected == false):
			building = load("res://models/Building Select Models/Base.tscn")
			building_selected = true
			building_type = 0
		
		# If a selected building was changed, make appropriate changes
		if (building_selected and building_type != 0):
			building = load("res://models/Building Select Models/Base.tscn")
			building_type = 0
			building_holo_active = false
			get_tree().get_root().get_node("./Main/Hologram/Building").queue_free()
			
		# If the key was pressed again and the holo is active and building is selected, check if its not inside an object. If not, create.
		if (building_holo_active and building_selected):
			var boundary = get_tree().get_root().get_node("./Main/Hologram/Building/Area3D/Boundary")
			if boundary.visible == false:
				building_confirmed = true
				
		# Proceed with Build
		if (building_confirmed):
			if(!selected.is_empty()):
				for unit in selected:
					if unit.is_in_group("gru"):
						unit.buildBase(clickTarget.position)
						
						building_confirmed = false
						building_holo_active = false
						building_selected = false
						building_type = -1
						get_tree().get_root().get_node("./Main/Hologram/Building").queue_free()
					
	if Input.is_action_just_pressed("buildCamp"):
		var clickTarget = raycastToMouse(m_pos)
		
		# If no building is selected currently, select this building
		if (building_selected == false):
			building = load("res://models/Building Select Models/training_camp.tscn")
			building_selected = true
			building_type = 1
			
		# If a selected building was changed, make appropriate changes
		if (building_selected and building_type != 1):
			building = load("res://models/Building Select Models/training_camp.tscn")
			building_type = 1
			building_holo_active = false
			get_tree().get_root().get_node("./Main/Hologram/Building").queue_free()
		
		# If the key was pressed again and the holo is active and building is selected, check if its not inside an object. If not, create.
		if (building_holo_active and building_selected):
			var boundary = get_tree().get_root().get_node("./Main/Hologram/Building/Area3D/Boundary")
			if boundary.visible == false:
				building_confirmed = true
				
		# Proceed with Build
		if (building_confirmed):
			if(!selected.is_empty()):
				for unit in selected:
					if unit.is_in_group("gru"):
						unit.buildCamp(clickTarget.position)
						
						building_confirmed = false
						building_holo_active = false
						building_selected = false
						building_type = -1
						get_tree().get_root().get_node("./Main/Hologram/Building").queue_free()
					
	if Input.is_action_just_pressed("buildTrap"):
		var clickTarget = raycastToMouse(m_pos)
		
		# If no building is selected currently, select this building
		if (building_selected == false):
			building = load("res://models/Building Select Models/tesla.tscn")
			building_selected = true
			building_type = 2
			
		# If a selected building was changed, make appropriate changes
		if (building_selected and building_type != 2):
			building = load("res://models/Building Select Models/tesla.tscn")
			building_type = 2
			building_holo_active = false
			get_tree().get_root().get_node("./Main/Hologram/Building").queue_free()
			
		# If the key was pressed again and the holo is active and building is selected, check if its not inside an object. If not, create.
		if (building_holo_active and building_selected):
			var boundary = get_tree().get_root().get_node("./Main/Hologram/Building/Area3D/Boundary")
			if boundary.visible == false:
				building_confirmed = true
				
		# Proceed with Build	
		if (building_confirmed):
			if(!selected.is_empty()):
				for unit in selected:
					if unit.is_in_group("gru"):
						unit.buildTrap(clickTarget.position)
						
						building_confirmed = false
						building_holo_active = false
						building_selected = false
						building_type = -1
						get_tree().get_root().get_node("./Main/Hologram/Building").queue_free()	
							

	if Input.is_action_just_pressed("patrol"):
		if buildingPatrol:
			for unit in selected:
					if not unit.is_in_group("units"):
						continue
					unit.setup_patrol(patrolPoints)
					
			patrolPoints.clear()
		buildingPatrol = !buildingPatrol

func disconnect_signals():
	for unit in selected:
			unit.unit_dead.disconnect(remove_dead_unit_from_selected)	

func raycastToMouse(m_pos):
	var result = raycast_from_mouse(m_pos, 3)
	return result

func calc_move(m_pos, delta):
	var v_size = get_viewport().size
	var move_vec = Vector3()
 
	if m_pos.x < MOVE_MARGIN:
		move_vec.x -= 1
	if m_pos.y < MOVE_MARGIN:
		move_vec.z -= 1
	if m_pos.x > v_size.x - MOVE_MARGIN:
		move_vec.x += 1
	if m_pos.y > v_size.y - MOVE_MARGIN:
		move_vec.z += 1
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation_degrees.y)
	global_translate(move_vec * delta * MOVE_SPEED)
	
func select_units(m_pos):
	var newSelected = []
	newSelected = get_units_in_box(boxStart, m_pos)
	selected = newSelected
	
	# attach unit dead signal
	for unit in selected:
		unit.unit_dead.connect(remove_dead_unit_from_selected)
 
func get_units_in_box(top_left, bot_right):
	if top_left.x > bot_right.x:
		var tmp = top_left.x
		top_left.x = bot_right.x
		bot_right.x = tmp
	if top_left.y > bot_right.y:
		var tmp = top_left.y
		top_left.y = bot_right.y
		bot_right.y = tmp
	var box = Rect2(top_left, bot_right - top_left)
	var box_selected_units = []
	for unit in get_tree().get_nodes_in_group("units"):
		if box.has_point(self.unproject_position(unit.global_transform.origin)):
			box_selected_units.append(unit)
	return box_selected_units
	
func raycast_from_mouse(m_pos, collision_mask):
	var ray_start = self.project_ray_origin(m_pos)
	var ray_end = ray_start + self.project_ray_normal(m_pos) * ray_length
	var space_state = get_world_3d().direct_space_state
	var rayQuery = PhysicsRayQueryParameters3D.create(ray_start, ray_end, collision_mask)
	return space_state.intersect_ray(rayQuery)

func remove_dead_unit_from_selected(dead_unit):
	selected.remove_at(selected.find(dead_unit))
