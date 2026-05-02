extends PlayerState

var _is_dead: bool = false

func enter(_prev: String, _data: Dictionary = {}) -> void:
	player.velocity.x = 0.0
	player.play_anim("death")
	_is_dead = false
	# Disable hurtbox so no more damage during death
	if player.has_node("Hurtbox"):
		player.get_node("Hurtbox").set_deferred("monitoring", false)

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.move_and_slide()
