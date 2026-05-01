extends Area2D

@export var target_map: String = ""

func _ready() -> void:
	print("=== PortalArea ready, target: ", target_map)
	
	var has_collision = false
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			has_collision = true
			print("PortalArea: collision shape found -> ", child.name)
	if not has_collision:
		print("WARNING: PortalArea has NO CollisionShape2D!")

func _on_body_entered(body: Node) -> void:
	print("--- body_entered fired ---")
	
	if body is Knight:
		if target_map == "":
			print("ERROR: target_map is empty! Set it in the Inspector")
			return
		print("Knight confirmed! Switching to: ", target_map)
		GameManager.switch_map(target_map)
	else:
		print("Not Knight, ignoring: ", body.name)
