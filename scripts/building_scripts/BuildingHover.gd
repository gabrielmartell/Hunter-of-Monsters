extends Node3D

var ignore_collision = ["Ground", "Sand", "Sand2", "Water"]
var inside = []

func _ready():
	$Boundary.visible = false

func _process(delta):
	if (inside.is_empty()):
		$Boundary.visible = false
	elif(inside.is_empty()==false):
		$Boundary.visible = true
	pass


func _on_body_entered(body):
	if ignore_collision.has(body.name):
		pass
	else:
		inside.append(body)

func _on_body_exited(body):
	inside.erase(body)

