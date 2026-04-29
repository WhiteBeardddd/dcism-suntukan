extends Area2D

@export var lines: Array[String] = []

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var prompt_label: Label = $Label

func _ready() -> void:
	prompt_label.hide()
	print("NPC ready, lines count: ", lines.size())

func _on_body_entered(body: Node2D) -> void:
	print("Something entered: ", body.name)
	if body.name == "knight":
		print("Player entered, dialog active: ", DialogManager.is_dialog_active)
		if not DialogManager.is_dialog_active:
			sprite.flip_h = body.global_position.x < global_position.x
			var spawn_position = global_position + Vector2(0, -50)
			print("Starting dialog with ", lines.size(), " lines")
			DialogManager.start_dialog(spawn_position, lines)

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		prompt_label.hide()
