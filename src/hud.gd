extends Node2D

var player: Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node("/root/Player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var bone_label = get_node("BoneTexture/BoneLabel")
	var food_label = get_node("FoodTexture/FoodLabel")
	var ore_label = get_node("OreTexture/OreLabel")
	
	bone_label.text = str(player.getBones())
	food_label.text = str(player.getFood())
	ore_label.text = str(player.getOre())
	
	var building_nodes = get_tree().get_nodes_in_group("buildings")
	var units = get_tree().get_nodes_in_group("units")
	
	if (units.is_empty() and building_nodes.is_empty()):
		Player.setOre(0)
		Player.setFood(0)
		Player.setBones(0)
		$GameOverLabel.visible = true

func _on_enemy_script_cleared_waves():
	$GameWinLabel.visible = true
	
