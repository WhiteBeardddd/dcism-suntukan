extends Control

func _on_start_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/maps/maps/Map1.tscn")

func _on_settings_btn_pressed() -> void:
	pass

func _on_exit_btn_pressed() -> void:
	get_tree().quit()
