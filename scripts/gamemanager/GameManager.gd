extends Node

const KNIGHT_SCENE = preload("res://scenes/characters/knight.tscn")

var player_hp: int = 100
var player_max_hp: int = 100
var player_score: int = 0
var inventory: Array = []

var current_map: String = "res://scenes/maps/Map1.tscn"
var spawn_point_name: String = "SpawnPoint"

signal stats_updated

func _ready() -> void:
	print("=== GameManager ready ===")
	reset_stats()

func reset_stats() -> void:
	player_hp     = 100
	player_max_hp = 100
	player_score  = 0
	inventory     = []

func set_hp(new_hp: int) -> void:
	player_hp = clamp(new_hp, 0, player_max_hp)
	emit_signal("stats_updated")

func take_damage(amount: int) -> void:
	set_hp(player_hp - amount)
	if player_hp <= 0:
		_on_player_died()

func heal(amount: int) -> void:
	set_hp(player_hp + amount)

func add_score(points: int) -> void:
	player_score += points
	emit_signal("stats_updated")

func spawn_knight(scene: Node) -> void:
	print("=== spawn_knight() called in: ", scene.name)

	# Check if knight already exists
	for child in scene.get_children():
		if child is Knight:
			print("Knight already exists, skipping")
			return

	var knight = KNIGHT_SCENE.instantiate()
	scene.add_child(knight)

	var spawn = scene.get_node_or_null(spawn_point_name)
	if spawn:
		knight.global_position = spawn.global_position
		print("Knight spawned at: ", knight.global_position)
	else:
		print("WARNING: SpawnPoint not found!")

func switch_map(map_path: String, spawn_name: String = "SpawnPoint") -> void:
	print("=== switch_map() called === ", map_path)

	if not FileAccess.file_exists(map_path):
		print("ERROR: Map file does not exist -> ", map_path)
		return

	current_map = map_path
	spawn_point_name = spawn_name
	get_tree().change_scene_to_file(map_path)

func _on_player_died() -> void:
	print("Player died! Restarting...")
	get_tree().change_scene_to_file(current_map)
	reset_stats()
