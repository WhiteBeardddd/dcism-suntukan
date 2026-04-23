# AttackController.gd
extends Node2D

@export var hitbox_scene: PackedScene

var facing_right := true

const ATTACK_DATA := {
	"attack1":       [12, 48,  0,  40, 28, 0.12],
	"attack2":       [18, 52,  0,  48, 32, 0.14],
	"attack3":       [25, 56, -4,  56, 36, 0.16],
	"crouch_attack": [10, 44,  8,  36, 20, 0.10],
}

func spawn_hitbox(attack_name: String) -> void:
	if not ATTACK_DATA.has(attack_name):
		return
	var cfg    = ATTACK_DATA[attack_name]
	var hitbox = hitbox_scene.instantiate()
	hitbox.damage   = cfg[0]
	hitbox.lifetime = cfg[5]
	var sign_x = 1.0 if facing_right else -1.0
	var knight = get_tree().get_first_node_in_group("player")
	var origin = knight.global_position
	hitbox.global_position = origin + Vector2(cfg[1] * sign_x, cfg[2])
	hitbox.scale.x = sign_x
	get_tree().current_scene.add_child(hitbox)
	hitbox.set_shape_size(Vector2(cfg[3], cfg[4]))
