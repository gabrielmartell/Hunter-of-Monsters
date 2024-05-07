class_name Harvestable

extends StaticBody3D

enum ResourceType {Bones, Ore, Food}

signal action(name, position)

@export var resourceType: ResourceType

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# ? What is this?
func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() == true:
			print(name)
			emit_signal("action",name, position)
	pass # Replace with function body.
