extends "res://scripts/unit_scripts/BaseUnit.gd"

@onready var anim_tree = $AnimationTree


func _ready():
	current_faction = FACTION.Friendly
	if healthbar:
		healthbar_offset = abs(healthbar.global_position.y - self.global_position.y)

func _process(delta):
	if moving:
		anim_tree["parameters/BlendSpace1D/blend_position"] = 1
	elif attacking == true:
		anim_tree["parameters/BlendSpace1D/blend_position"] = 2
	else:
		anim_tree["parameters/BlendSpace1D/blend_position"] = 0
	
	
