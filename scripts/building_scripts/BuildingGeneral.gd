extends Node3D

signal unit_dead(thisptr)

@export var healthbar: Node3D
var healthbar_offset: float

enum FACTION {Friendly, Hostile, None}
var current_faction: FACTION = FACTION.Friendly

#variables. Just randomly set default values
@export var hp = 100
var hp_max = hp
var cost = 50
var destroyed = false

#variables required to train units. Might move away if we want buildings that can only upgrade
var queue = []
var max_queue_size = 5
var queue_timer = 0

func _ready():
	if healthbar:
		healthbar_offset = abs(healthbar.global_position.y - self.global_position.y)

func _process(delta):
	if healthbar:
		var mat = healthbar.get_surface_override_material(0)
		
		mat.set_shader_parameter("percentage", hp / hp_max)
		
		healthbar.global_position = self.global_position
		healthbar.global_position.y += healthbar_offset
	
	
#damage the building
func on_damage(damage):
	hp -= damage
	if hp <= 0:
		destroyBuilding()

#destroy building
func destroyBuilding()->void:
	destroyed = true
	unit_dead.emit(self)
