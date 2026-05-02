extends PlayerState

var _is_hit_done: bool = false

func enter(_prev: String, _data: Dictionary = {}) -> void:
	player.velocity.x = 0.0
	player.play_anim("hit")
	_is_hit_done = false

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.move_and_slide()
