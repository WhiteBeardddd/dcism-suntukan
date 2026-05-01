extends Node2D

func _ready() -> void:
	print("Map ready: ", name)
	GameManager.spawn_knight(self)
