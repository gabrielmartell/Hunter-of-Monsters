extends Node3D

#preload required units
var groundEnemy = preload("res://models/Unit Models/enemyground.tscn")
var airEnemy = preload("res://models/Unit Models/airmonster.tscn")

signal cleared_waves

var clearedAllWaves = false
var currentWave = 1
var lastWave	# match with total waves
var waveTimer = 60  # Time until next wave in seconds
var timeSinceLastEnemy = 0  # Time since the last enemy was killed
var enemies = [] #array containing all enemies
var allSpawns = [Vector3(-60,0,10),Vector3(60,0,10),Vector3(0,0,60),Vector3(0,0,-60)]
var rng = RandomNumberGenerator.new()

# index 0 = melee, index 1 = air
var waveDetails = {
	#"wave0": [0, 0],
	"wave1": [1, 1],
	"wave2": [5, 0],
	"wave3": [6, 2],
	"wave4": [12, 4],
	"wave5": [24, 8],
	"wave6": [48, 16],
	"wave7": [100, 30]
}

func _ready():
	lastWave = waveDetails.size()
	clearedAllWaves = false	#stops monster from spawning testing puroses

func _process(delta):
	
	#when waves remain
	if not clearedAllWaves:
		#check if all enemies are dead or if there are no enemies
		if enemies.size() <= 0:
		# Increment time since last enemy
			timeSinceLastEnemy += delta
			# Check if it's time to start the next wave
			if timeSinceLastEnemy >= waveTimer:
				# Start the next wave
				startNextWave()
	
	#no waves remain
	else:
		#print("All waves cleared")
		#game over signal can be sent out
		pass
		

func startNextWave():
	#if there are no more waves, then sent clear condition to true
	if currentWave > lastWave:
		clearedAllWaves = true
		emit_signal("cleared_waves")
		return
		
	var wave = waveDetails["wave" + str(currentWave)]
	var groundNum = wave[0]	#ground enemies
	var airNum = wave[1]	#air enemies
	
	var enemyUnit
	#spawn units
	for i in groundNum:
		enemyUnit = groundEnemy.instantiate()
		enemyUnit.add_to_group("enemyUnits")	#add to appropriate group
		var spawnIndex = rng.randi_range(0,3)
		var spawnPos = allSpawns[spawnIndex]
		var offset = rng.randf_range(5.0,-5.0)
		spawnPos.x = spawnPos.x+offset
		offset = rng.randf_range(5.0,-5.0)
		spawnPos.z = spawnPos.z+offset
		enemyUnit.position = spawnPos
		get_tree().get_root().get_node("./Main/EnemyUnits").add_child(enemyUnit)	#add to enemyUnits node in scene
		enemies.append(enemyUnit)	# add to enemies array
		enemyUnit.unit_dead.connect(remove_dead_enemy)
		
	for i in airNum:
		enemyUnit = airEnemy.instantiate()
		enemyUnit.add_to_group("enemyUnits")	#add to appropriate group
		var spawnIndex = rng.randi_range(0,3)
		var spawnPos = allSpawns[spawnIndex]
		var offset = rng.randf_range(5.0,-5.0)
		spawnPos.x = spawnPos.x+offset
		offset = rng.randf_range(5.0,-5.0)
		spawnPos.z = spawnPos.z+offset
		enemyUnit.position = spawnPos + Vector3(0, 4, 0)
		get_tree().get_root().get_node("./Main/EnemyUnits").add_child(enemyUnit)	#add to enemyUnits node in scene
		enemies.append(enemyUnit)	# add to enemies array
		enemyUnit.unit_dead.connect(remove_dead_enemy)
		
	currentWave += 1

func remove_dead_enemy(enemy):
	enemies.remove_at(enemies.find(enemy))
	
	if enemies.size() == 0:
		timeSinceLastEnemy = 0
