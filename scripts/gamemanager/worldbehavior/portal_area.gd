extends Area2D

@export var target_map: String = ""

func _ready() -> void:
	var has_collision = false
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			has_collision = true
	if not has_collision:
		push_warning("PortalArea has no CollisionShape2D!")

func _on_body_entered(body: Node) -> void:
	if body is Knight:
		if target_map == "":
			push_warning("PortalArea: target_map is empty!")
			return
		GameManager.switch_map(target_map)
