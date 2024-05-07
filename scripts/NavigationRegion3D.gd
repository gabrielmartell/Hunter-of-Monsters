extends NavigationRegion3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_child_update_navigation(node: Node3D):
	self.add_child(node)
	self.bake_navigation_mesh()
	
func update_navigation():
	self.bake_navigation_mesh()
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	for child in $Buildings.get_children():
		if child.destroyed:
			child.free()
			update_navigation()
