extends "res://scripts/building_scripts/BuildingGeneral.gd"

@export var damage = 50.0



func _on_body_entered(body):
	pass


func _on_area_3d_body_entered(body):
	#check if body is an enemy, then deal damage
	if body.is_in_group("enemyUnits"):
		body.on_damage(damage)
		queue_free()
